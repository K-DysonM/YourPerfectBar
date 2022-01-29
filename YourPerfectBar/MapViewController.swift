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
		mapView = MKMapView(frame: view.bounds)
		mapView.showsUserLocation = true
		mapView.delegate = self
		mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		let initialRegion = MKCoordinateRegion(center: INITIAL_COORDINATE, span: MKCoordinateSpan(latitudeDelta: LOCATION_ZOOM_LEVEL, longitudeDelta: LOCATION_ZOOM_LEVEL))
		mapView.setRegion(initialRegion, animated: true)
		
		// CollectionView setup
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 300, height: 200)
		layout.scrollDirection = .horizontal
		collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(mapView)
		view.addSubview(collectionView)
		NSLayoutConstraint.activate(
			[collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.00),
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
		
		#warning("api calls should be moved off main thread")
		#warning("exact api calls being made twice- make optimization to somehow share the data returned by this")
		yelpAPIClient.searchBusinesses(
			byTerm: "bars",
			location: "New York City",
			latitude: nil,
			longitude: nil,
			radius: 5000,
			categories: nil,
			locale: .english_unitedStates,
			limit: 20,
			offset: nil,
			sortBy: .bestMatch,
			priceTiers: nil,
			openNow: nil,
			openAt: nil,
			attributes: nil) { [weak self] cdYelpSearchResponse in
			guard let businesses = cdYelpSearchResponse?.businesses else { return }
			self?.bars = businesses
			self?.collectionView.reloadData()
			self?.collectionView.scrollToItem(at: IndexPath(row: 4, section: 0), at: .centeredHorizontally, animated: false)
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
	
}
