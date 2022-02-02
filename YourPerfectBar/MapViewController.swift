//
//  MapViewController.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/28/22.
//

import UIKit
import MapKit
import CoreLocation
import CDYelpFusionKit

class MapViewController: UIViewController {
	let yelpAPIClient = CDYelpAPIClient(apiKey: Configuration().yelpApiKey)
	var barAnnotations = [BarMKAnnotation]()
	var barsModel: BarsModel!
	
	private(set) var LOCATION_ZOOM_LEVEL: CLLocationDegrees = 0.05
	let screenSize: CGRect = UIScreen.main.bounds
	var locationManager: CLLocationManager?
	var mapView: MKMapView!
	var button: UIButton!
	var collectionView: UICollectionView!
	
	
	let INITIAL_COORDINATE: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855)
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .white
		// MapView setup
		mapView = MKMapView()
		mapView.showsUserLocation = true
		mapView.delegate = self
		mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		mapView.translatesAutoresizingMaskIntoConstraints = false
		
		// CollectionView setup
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 300, height: 200)
		layout.scrollDirection = .horizontal
		collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		// Button setup
		button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "x.square"), for: .normal)
		button.backgroundColor = .white
		button.addTarget(self, action: #selector(removeMKPolygons), for: .touchDown)
		button.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(mapView)
		view.addSubview(collectionView)
		view.addSubview(button)
		NSLayoutConstraint.activate(
			[mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			 mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			 mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
			 mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
			 collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.00),
			 collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
			 collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
			 collectionView.heightAnchor.constraint(equalToConstant: 200.00),
			 button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			 button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
			 button.heightAnchor.constraint(equalToConstant: 50.00),
			 button.widthAnchor.constraint(equalToConstant: 50.00)
			]
		)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar setup
		let searchBar = UISearchBar()
		searchBar.placeholder = "Search A Bar..."
		navigationItem.titleView = searchBar
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(showListView))
	
		let locationButton = UIBarButtonItem(image: UIImage(systemName: "location.fill.viewfinder"), style: .plain, target: self, action: #selector(setMapToCurrentLocation))
		let searchDrawButton = UIBarButtonItem(image: UIImage(systemName: "hand.draw"), style: .plain, target: self, action: #selector(setDrawOnMap))
		navigationItem.rightBarButtonItems = [locationButton, searchDrawButton]
		// Location setup
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.requestAlwaysAuthorization()
		
		// Collection View setup
		collectionView.backgroundColor = .clear
		collectionView.register(UINib(nibName: "BarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Bar")
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.delegate = self
		collectionView.dataSource = self
		
		// MapView setup
		let initialRegion = MKCoordinateRegion(center: INITIAL_COORDINATE, span: MKCoordinateSpan(latitudeDelta: LOCATION_ZOOM_LEVEL, longitudeDelta: LOCATION_ZOOM_LEVEL))
		mapView.setRegion(initialRegion, animated: true)
		mapView.isUserInteractionEnabled = true

		self.searchForBarsAt(coordinate: nil, location: "New York City")
    }
	/// Adds an array of bars as BarMKAnnotations to the map view
	func addMKAnnotations(forBars list: [CDYelpBusiness]?) {
		guard let list = list else { return }
		let newAnnotations = list.compactMap { convertToBarMKAnnotation(from: $0) }
		mapView.addAnnotations(newAnnotations)
		barAnnotations += newAnnotations
	}
	
	func convertToBarMKAnnotation(from business: CDYelpBusiness) -> BarMKAnnotation? {
		let latitude = business.coordinates?.latitude
		let longitude = business.coordinates?.longitude
		guard let latitude = latitude, let longitude = longitude  else { return nil }
		let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		let barMKAnnotation = BarMKAnnotation(id: business.id, coordinate: location, name: business.name, rating: business.rating)
		return barMKAnnotation
	}
	
	
	/// Removes an array of BarMKAnnotation objects from the map view.
	func removeMKAnnotations(forBars list: [BarMKAnnotation]?) {
		guard let list = list else { return }
		mapView.removeAnnotations(list)
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
		mapView.removeAnnotations(barsOutside)
	}
	
	/// Removes MKPolygon objects from the map view.
	@objc
	func removeMKPolygons() {
		mapView.removeOverlays(mapView.overlays.compactMap { $0 as? MKPolygon })
	}
	/// Adds an array of MKPolygon objects to the map view
	func addMKPolygons(polygons: [MKPolygon]) {
		mapView.addOverlays(polygons)
		removeMKAnnotations(forBars: barAnnotations, outside: polygons)
	}
	
	func searchForBarsAt(coordinate: CLLocationCoordinate2D?, location: String?) {
		DispatchQueue.global().async {
			self.yelpAPIClient.searchBusinesses(
				byTerm: "bars",
				location: location,
				latitude: coordinate?.latitude,
				longitude: coordinate?.longitude,
				radius: 5000,
				categories: nil,
				locale: .english_unitedStates,
				limit: 50,
				offset: nil,
				sortBy: .bestMatch,
				priceTiers: nil,
				openNow: nil,
				openAt: nil,
				attributes: nil) {[weak self] cdYelpSearchResponse in
				guard let businesses = cdYelpSearchResponse?.businesses else { return }
				self?.barsModel.bars = []
				// ONLY SHOW ANNOTATIONS IF WITHIN THE FRAME -
				for business in businesses {
					if let latitude = business.coordinates?.latitude, let longitude = business.coordinates?.longitude {
						let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
						if let contains = self?.mapView.visibleMapRect.contains(MKMapPoint(coordinate)) {
							if contains {
								self?.barsModel.bars.append(business)
							}
						}
					}
				}
				let middleIndex = businesses.count/2
				
				DispatchQueue.main.async {
					self?.collectionView.reloadData()
					self?.collectionView.scrollToItem(at: IndexPath(row: middleIndex, section: 0), at: .centeredHorizontally, animated: false)
					self?.removeMKAnnotations(forBars: self?.barAnnotations)
					self?.addMKAnnotations(forBars: self?.barsModel.bars)
				}
			}
		}
	}
	
	@objc
	func showListView() {
		tabBarController?.selectedIndex = 0
	}
	@objc
	func setMapToCurrentLocation() {
		if locationManager?.authorizationStatus == .authorizedAlways {
			if let coordinate = locationManager?.location?.coordinate {
				let coordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: LOCATION_ZOOM_LEVEL, longitudeDelta: LOCATION_ZOOM_LEVEL))
				mapView.setRegion(coordinateRegion, animated: true)
			}
		} else {
			let ac = UIAlertController(title: "Access Restricted", message: "App doesn't have permission to use your location", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		}
	}
	// NAVIGATE USER TO DRAW MODE
	@objc
	func setDrawOnMap() {
		let vc = DrawMapViewController()
		vc.region = mapView.region
		navigationController?.pushViewController(vc, animated: true)
	}
}
extension MapViewController: CLLocationManagerDelegate {
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if manager.authorizationStatus == .authorizedAlways {
			//
		}
	}
}
// COLLECTIONVIEW METHODS
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return barsModel.bars.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Bar", for: indexPath) as? BarCollectionViewCell else {
			fatalError("BarCollectionViewCell not properly initialized")
		}
		let bar = barsModel.bars[indexPath.item]
		cell.barTitleLabel.text = bar.name
		cell.barImageView.contentMode = .scaleAspectFill
		#warning("Look into if the preferred way is to have direct access to the imageView like this")
		cell.barImageView.sd_setImage(with: bar.imageUrl, placeholderImage: UIImage(systemName: "music.house"))
		return cell
	}
}
// MAPVIEW METHODS
extension MapViewController: MKMapViewDelegate {
	#warning("Should actually search for bars but keep in mind the overlays. So don't search for bars in those overlays. This could be a parameter that can be nil in the case you don't need to search within an overlay ")
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		collectionView.isHidden = true
		searchForBarsAt(coordinate: mapView.centerCoordinate, location: nil)
	}
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard let annotation = annotation as? BarMKAnnotation else { return nil }
		
		let identifier = "Bar"
		let annotationView: MKAnnotationView
		if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
			annotationView = existingView
		} else {
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
		}
		#warning("Implement a unique identifier image for annotation view")
		annotationView.image = annotation.image
		annotationView.canShowCallout = true
		return annotationView
	}
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let annotation = view.annotation as? BarMKAnnotation else { return }
		guard let index = barsModel.bars.firstIndex(where: { cdYelpBusiness in
			cdYelpBusiness.id == annotation.id
		}) else { return }
		#warning("Bug where if animated is true it doesn't scrollToItem")
		collectionView.isHidden = false
		print(index)
		collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
	}
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is MKPolygon {
			let polygonView = MKPolygonRenderer(overlay: overlay)
			polygonView.strokeColor = UIColor(named: "HunterGreen")
			polygonView.lineWidth = 5
			polygonView.fillColor = .lightGray.withAlphaComponent(0.3)
			
			return polygonView
		}
		return MKPolylineRenderer(overlay: overlay)
	}
}
