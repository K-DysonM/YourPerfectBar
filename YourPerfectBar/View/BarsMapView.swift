//
//  BarsMapView.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/5/22.
//

import UIKit
import MapKit
import CDYelpFusionKit

class BarsMapView: MKMapView {
	let INITIAL_COORDINATE: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855)
	var LOCATION_ZOOM_LEVEL: CLLocationDegrees = 0.05
	init() {
		super.init(frame: .zero)
		createSubviews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func createSubviews() {
		let initialRegion = MKCoordinateRegion(center: INITIAL_COORDINATE, span: MKCoordinateSpan(latitudeDelta: LOCATION_ZOOM_LEVEL, longitudeDelta: LOCATION_ZOOM_LEVEL))
		setRegion(initialRegion, animated: true)
		
		showsUserLocation = true
		autoresizingMask = [.flexibleWidth, .flexibleHeight]
		isUserInteractionEnabled = true
	}
    
	/// Adds an array of bars as BarMKAnnotations to the map view
	func addMKAnnotations(forBars list: [CDYelpBusiness]?) -> [BarMKAnnotation] {
		guard let list = list else { return [] }
		let newAnnotations = list.compactMap { convertToBarMKAnnotation(from: $0) }
		addAnnotations(newAnnotations)
		return newAnnotations
	}
	
	/// Removes an array of BarMKAnnotation objects from the map view.
	func removeMKAnnotations(forBars list: [BarMKAnnotation]?) {
		guard let list = list else { return }
		removeAnnotations(list)
		
	}
	
	/// Removes an array of BarMKAnnotation objects outside an array of MKPolygon objects from the map view.
	func removeMKAnnotations(forBars bars: [BarMKAnnotation], outside polygons: [MKPolygon] ) {
		/// A list of bars not within any of the given map polygons
		let barsOutside = bars.filter { (bar) in
			for polygon in polygons {
				if polygon.contain(coor: bar.coordinate) {
					return false
				}
			}
			return true
		}
		removeAnnotations(barsOutside)
	}
	/// Removes MKPolygon objects from the map view.
	@objc
	func removeMKPolygons() {
		removeOverlays(overlays.compactMap { $0 as? MKPolygon })
	}
	
	#warning("I think this should be moved to the model CDYelpBusiness class")
	func convertToBarMKAnnotation(from business: CDYelpBusiness) -> BarMKAnnotation? {
		let latitude = business.coordinates?.latitude
		let longitude = business.coordinates?.longitude
		guard let latitude = latitude, let longitude = longitude  else { return nil }
		let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		let barMKAnnotation = BarMKAnnotation(id: business.id, coordinate: location, name: business.name, rating: business.rating)
		
		return barMKAnnotation
	}

}
