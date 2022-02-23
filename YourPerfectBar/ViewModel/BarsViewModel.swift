//
//  BarsViewModel.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/15/22.
//

import UIKit
import CDYelpFusionKit
import MapKit
import CoreLocation
import Combine
import GooglePlaces

class BarsViewModel: NSObject {
	// yelp
	let yelpService = CDYelpAPIClient(apiKey: YELP_API_KEY)
	// location
	let locationService = LocationServicer()
	// google places autocomplete
	private var placesClient = GMSPlacesClient.shared()
	
	// bars
	@Published private(set) var currentBars: [CDYelpBusiness] = []
	
	// optional bars filter
	private(set) var filter: ((CDYelpBusiness) throws -> Bool)?
	
	override init() {
		locationService.requestLocation()
	}
	
	
	func fetchUserLocationCoordinate() -> CLLocationCoordinate2D? {
		return locationService.locationManager.location?.coordinate
	}
	func removeAllCurrentBars() {
		currentBars.removeAll(keepingCapacity: true)
	}
	
	// causing same bars to be drawn over and over again
	// not researching area when you zoom in
	#warning("theres a way to make functions take one or many items ")
	func fetchBarsAtPolygons(_ polygons: [MKPolygon]) {
		print("fetchBarsAtPolygons called")
		for polygon in polygons {
			print("Latitude: \(polygon.coordinate.latitude)", "Longitude: \(polygon.coordinate.longitude))")
			DispatchQueue.global().async {
				self.yelpService.searchBusinesses(
					byTerm: "bars",
					location: nil,
					latitude: polygon.coordinate.latitude,
					longitude: polygon.coordinate.longitude,
					radius: 3000,
					categories: nil,
					locale: .english_unitedStates,
					limit: 40,
					offset: nil,
					sortBy: nil,
					priceTiers: nil,
					openNow: nil,
					openAt: nil,
					attributes: nil) {[weak self] response in
					guard let bars = response?.businesses else { return }
					print("yelpService.searchBusinesses called")
					let filteredBars = bars.filter({ business in
						if let lat = business.coordinates?.latitude, let long = business.coordinates?.longitude {
							return polygon.contain(coor: CLLocationCoordinate2D(latitude: lat, longitude: long))
						} else {
							return false
						}
					})
						
					self?.currentBars += filteredBars
					
				}
			}
		}
	}
	
	
	
	func fetchBarsAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
		DispatchQueue.global().async {
			self.yelpService.searchBusinesses(
				byTerm: "bars",
				location: nil,
				latitude: coordinate.latitude,
				longitude: coordinate.longitude,
				radius: 5000,
				categories: nil,
				locale: .english_unitedStates,
				limit: 15,
				offset: nil,
				sortBy: .bestMatch,
				priceTiers: nil,
				openNow: nil,
				openAt: nil,
				attributes: nil) {[weak self] response in
				guard let bars = response?.businesses else { return }
				if let filter = self?.filter, let filteredBars =  try? bars.filter(filter) {
					self?.currentBars = filteredBars
				} else {
					self?.currentBars = bars
				}
			}
		}
	}
	
	func fetchAutocompletePredictions(text: String, inTopLeftCoordinate c1: CLLocationCoordinate2D, inBottomRightCoordinate c2: CLLocationCoordinate2D ){
		let token = GMSAutocompleteSessionToken.init()
		// Create a type filter.
		let filter = GMSAutocompleteFilter()
		filter.type = .establishment
		filter.locationBias = GMSPlaceRectangularLocationOption(c1, c2)
		
		
		placesClient.findAutocompletePredictions(
			fromQuery: text,
			filter: filter,
			sessionToken: token,
			callback: { [weak self] (results, error) in
				if let error = error {
					print("Autocomplete error: \(error)")
					return
				}
				if let results = results {
					let businesses = results.compactMap { result -> Business in
						let name = result.attributedPrimaryText.string
						let location = result.attributedSecondaryText?.string ?? ""
						return Business(name: name, location: location)
					}
					// Update list of bars
					self?.currentBars.removeAll(keepingCapacity: true)
					self?.convertBusinessestoCDYelpBusinesses(businesses)
					
				}
			})
	}
	
	private func convertBusinessestoCDYelpBusinesses(_ places: [Business]) {

		for place in places {
			yelpService.searchBusinesses(
				name: place.name,
				addressOne: place.location,
				addressTwo: nil,
				addressThree: nil,
				city: "New York City",
				state: "NY",
				country: "US",
				latitude: nil,
				longitude: nil,
				phone: nil,
				zipCode: nil,
				yelpBusinessId: nil,
				limit: 1,
				matchThresholdType: .normal) { (response) in
				
				if let response = response, let business = response.businesses?.first {
					self.currentBars.append(business)
				}
				
			}
		}
	}
	
	func setFilter(_ isIncluded: @escaping (CDYelpBusiness) throws -> Bool) {
		filter = isIncluded
	}
}
