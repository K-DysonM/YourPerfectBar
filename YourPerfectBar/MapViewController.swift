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
	var bars = [CDYelpBusiness]()
	
	private(set) var LOCATION_ZOOM_LEVEL: CLLocationDegrees = 0.05
	let screenSize: CGRect = UIScreen.main.bounds
	var locationManager: CLLocationManager?
	var mapView: MKMapView!
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
		view.addSubview(mapView)
		view.addSubview(collectionView)
		NSLayoutConstraint.activate(
			[mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			 mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			 mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
			 mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
			 collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.00),
			 collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
			 collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
			 collectionView.heightAnchor.constraint(equalToConstant: 200.00)
			]
		)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		let searchBar = UISearchBar()
		searchBar.placeholder = "Search A Bar..."
		navigationItem.titleView = searchBar
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(showListView))
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location.fill.viewfinder"), style: .plain, target: self, action: #selector(setMapToCurrentLocation))
		
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
		
		#warning("api calls should be moved off main thread")
		#warning("exact api calls being made twice- make optimization to somehow share the data returned by this")
		searchForBarsAt(coordinate: nil, location: "New York City")
		
		
    }
	func updateMKAnnotations() {
		for business in bars {
			let latitude = business.coordinates?.latitude
			let longitude = business.coordinates?.longitude
			guard let latitude = latitude, let longitude = longitude else { return }
			let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
			let barMKAnnotation = BarMKAnnotation(id: business.id, coordinate: location, name: business.name, rating: business.rating)
			mapView.addAnnotation(barMKAnnotation)
		}
	}
	
	func searchForBarsAt(coordinate: CLLocationCoordinate2D?, location: String?) {
		yelpAPIClient.searchBusinesses(
			byTerm: "bars",
			location: location,
			latitude: coordinate?.latitude,
			longitude: coordinate?.longitude,
			radius: 5000,
			categories: nil,
			locale: .english_unitedStates,
			limit: 20,
			offset: nil,
			sortBy: .bestMatch,
			priceTiers: nil,
			openNow: nil,
			openAt: nil,
			attributes: nil) {[weak self] cdYelpSearchResponse in
			guard let businesses = cdYelpSearchResponse?.businesses else { return }
			self?.bars = businesses
			self?.collectionView.reloadData()
			self?.collectionView.scrollToItem(at: IndexPath(row: 4, section: 0), at: .centeredHorizontally, animated: false)
			self?.updateMKAnnotations()
		}
	}
	
	@objc func showListView() {
		tabBarController?.selectedIndex = 0
	}
	@objc func setMapToCurrentLocation() {
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
}
extension MapViewController: CLLocationManagerDelegate {
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if manager.authorizationStatus == .authorizedAlways {
			//
		}
	}
}
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return bars.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Bar", for: indexPath) as? BarCollectionViewCell else { return UICollectionViewCell() }
		let bar = bars[indexPath.row]
		cell.barTitleLabel.text = bar.name
		cell.barImageView.contentMode = .scaleAspectFill
		#warning("Look into if the preferred way is to have direct access to the imageView like this")
		cell.barImageView.sd_setImage(with: bar.imageUrl, placeholderImage: UIImage(systemName: "music.house"))
		return cell
	}
}
extension MapViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
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
		annotationView.image = annotation.image
		annotationView.canShowCallout = true
		return annotationView
	}
	
}