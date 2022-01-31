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
	var collectionView: UICollectionView!
	
	let INITIAL_COORDINATE: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855)
	
	//DRAWING VARIABLES
	private var currentPath = UIBezierPath()
	private var currentLayer = CAShapeLayer()
	var points = [CLLocationCoordinate2D]()
	var lastPoint = CGPoint.zero
	var firstPoint = CGPoint.zero
	var drawMode = false
	
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
	
		let locationButton = UIBarButtonItem(image: UIImage(systemName: "location.fill.viewfinder"), style: .plain, target: self, action: #selector(setMapToCurrentLocation))
		let searchDrawButton = UIBarButtonItem(image: UIImage(systemName: "hand.draw"), style: .plain, target: self, action: #selector(setDrawOnMap))
		navigationItem.rightBarButtonItems = [locationButton,searchDrawButton]
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
		
		// Drawing setup

		
		#warning("api calls should be moved off main thread")
		#warning("exact api calls being made twice- make optimization to somehow share the data returned by this")
		searchForBarsAt(coordinate: nil, location: "New York City")
		
		
    }
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if drawMode {
			guard let touch = touches.first else { return }
			// Initialized for new drawing
			lastPoint = touch.location(in: view)
			firstPoint = lastPoint
			currentLayer = CAShapeLayer()
			currentPath = UIBezierPath()
			view.layer.addSublayer(currentLayer)
		} else {
			super.touchesBegan(touches, with: event)
		}
	}
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if drawMode {
			guard let touch = touches.first else { return }
			let currentPoint = touch.location(in: view)
			drawLine(from: lastPoint, to: currentPoint)
			lastPoint = currentPoint
		} else {
			super.touchesBegan(touches, with: event)
		}
	}
	
	func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
		currentPath.move(to: fromPoint)
		currentPath.addLine(to: toPoint)
		currentLayer.strokeColor = UIColor(named: "HunterGreen")?.withAlphaComponent(0.7).cgColor
		currentLayer.fillColor = nil
		currentLayer.lineWidth = 5.0
		currentLayer.lineCap = .round
		currentLayer.lineJoin = .round
		currentLayer.path = currentPath.cgPath
	}
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Close the drawing path by connecting the end to the beginning
		if drawMode {
			currentPath.addLine(to: firstPoint)
			currentLayer.path = currentPath.cgPath
			
		} else {
			super.touchesBegan(touches, with: event)
		}
	}
	func updateMKAnnotations() {
		for business in barsModel.bars {
			let latitude = business.coordinates?.latitude
			let longitude = business.coordinates?.longitude
			guard let latitude = latitude, let longitude = longitude else { return }
			let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
			let barMKAnnotation = BarMKAnnotation(id: business.id, coordinate: location, name: business.name, rating: business.rating)
			mapView.addAnnotation(barMKAnnotation)
			barAnnotations.append(barMKAnnotation)
		}
	}
	func removeMKAnnotations() {
		let rect = mapView.visibleMapRect
		let mapViewAnnotations = mapView.annotations(in: rect)
		for annotation in mapView.annotations {
			guard let annotationAnyHashable = annotation as? AnyHashable else { return }
			if !mapViewAnnotations.contains(annotationAnyHashable) {
				mapView.removeAnnotation(annotation)
			}
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
			limit: 5,
			offset: nil,
			sortBy: .bestMatch,
			priceTiers: nil,
			openNow: nil,
			openAt: nil,
			attributes: nil) {[weak self] cdYelpSearchResponse in
			guard let businesses = cdYelpSearchResponse?.businesses else { return }
			self?.barsModel.bars = businesses
			self?.collectionView.reloadData()
			let middleIndex = businesses.count/2
			self?.collectionView.scrollToItem(at: IndexPath(row: middleIndex, section: 0), at: .centeredHorizontally, animated: false)
			self?.updateMKAnnotations()
			self?.removeMKAnnotations()
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
	@objc func setDrawOnMap() {
		// Exit or enter drawMode
		drawMode = !drawMode
		//If in draw mode then remove uitouches to mapview else mapview receives uitouches
		if drawMode {
			let ac = UIAlertController(title: "Entering Draw Mode", message: "Draw a shape around an area to search", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "Start", style: .default))
			present(ac, animated: true)
			mapView.isUserInteractionEnabled = false
		} else {
			mapView.isUserInteractionEnabled = true
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
		return barsModel.bars.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Bar", for: indexPath) as? BarCollectionViewCell else { return UICollectionViewCell() }
		let bar = barsModel.bars[indexPath.row]
		cell.barTitleLabel.text = bar.name
		cell.barImageView.contentMode = .scaleAspectFill
		#warning("Look into if the preferred way is to have direct access to the imageView like this")
		cell.barImageView.sd_setImage(with: bar.imageUrl, placeholderImage: UIImage(systemName: "music.house"))
		return cell
	}
}
extension MapViewController: MKMapViewDelegate {
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
		if overlay is MKPolyline {
			let polylineRenderer = MKPolylineRenderer(overlay: overlay)
			polylineRenderer.strokeColor = UIColor(named: "HunterGreen")
			polylineRenderer.lineWidth = 5
			print("returned")
			return polylineRenderer
		} else if overlay is MKPolygon {
			let polygonView = MKPolygonRenderer(overlay: overlay)
			polygonView.strokeColor = UIColor(named: "HunterGreen")
			polygonView.lineWidth = 5
			polygonView.fillColor = .lightGray.withAlphaComponent(0.3)
			return polygonView
		} else if overlay is MKCircle{

		}
		
		return MKPolylineRenderer(overlay: overlay)
	}
	
	
}
