//
//  MapViewController.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/28/22.
//

import UIKit
import MapKit
import CoreLocation
import Combine
import Cartography


class MapViewController: UIViewController, SearchBarReceiverProtocol, DrawingMapDelegate {
	var barsViewModel: BarsViewModel!
	private var cancellables: Set<AnyCancellable> = []
	
	var barAnnotations = [BarMKAnnotation]()
	var bars: [Any] = []
	
	var mapView: BarsMapView!
	var dataSource = BarCollectionDataSource()
	
	var drawMode = false
	var polygons: [MKPolygon] = []
	
	lazy var collectionView: BarsCollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 300, height: 200)
		layout.minimumInteritemSpacing = 5
		layout.minimumLineSpacing = 5
		layout.scrollDirection = .horizontal
		let collectionView = BarsCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.dataSource = dataSource
		collectionView.delegate = dataSource
		return collectionView
	}()
	
	lazy var clearDrawView: DrawClearUIView = {
		let uiview = DrawClearUIView()
		uiview.clearDrawButton.addTarget(self, action: #selector(promptRemoveDrawUI), for: .touchDown)
		return uiview
	}()
	
	lazy var searchResultView: SearchResultsUIView = {
		return SearchResultsUIView()
	}()
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .white
		mapView = BarsMapView()
		
		[mapView, collectionView, searchResultView].forEach {
			view.addSubview($0)
		}
		constrain(mapView, collectionView, searchResultView) { mapView, collectionView, searchResultView in
			let superview = mapView.superview!.safeAreaLayoutGuide
			
			align(top: superview, mapView)
			align(right: superview, mapView, collectionView)
			align(left: superview, mapView, collectionView)
			align(bottom: superview, mapView, collectionView)
			searchResultView.centerX == superview.centerX
			searchResultView.height == 30
			searchResultView.width == 100
			searchResultView.bottom == superview.bottom - 10
			collectionView.height == 250
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar setup
		let locationButton = UIBarButtonItem(image: UIImage(systemName: "location.viewfinder"), style: .plain, target: self, action: #selector(setMapToCurrentLocation))
		let drawButton = UIBarButtonItem(image: UIImage(systemName: "hand.draw"), style: .plain, target: self, action: #selector(openDrawUI))
		let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearchUI))
		navigationItem.leftBarButtonItems = [searchButton, drawButton]
		navigationItem.rightBarButtonItems = [locationButton]
		navigationController?.navigationBar.tintColor = DEFAULT_TINT
		
		// MapView setup
		mapView.delegate = self
		mapView.showsCompass = false
		mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
		
		// ViewModel setup
		dataSource.objects = []
		barsViewModel.setFilter { business in
			self.mapView.visibleMapRect.contain(latitude: business.coordinates?.latitude, longitude: business.coordinates?.longitude)
		}
		
		barsViewModel.$currentBars.sink { [weak self] bars in
			self?.dataSource.objects = bars
			self?.updateMapUI()
			self?.updateCollectionViewUI()
			self?.updateSearchResultsViewUI()
			self?.searchResultView.setResultCount(bars.count)
		}.store(in: &cancellables)
		
		barsViewModel.fetchBarsAtCoordinate(mapView.INITIAL_COORDINATE)
    }
	func updateSearchResultsViewUI() {
		DispatchQueue.main.async {
			
		}
	}
	
	func updateMapUI() {
		// Remove the current MKAnnotations
		DispatchQueue.main.async {
			self.mapView.removeMKAnnotations(forBars: self.barAnnotations)
			self.barAnnotations.removeAll(keepingCapacity: true)
			self.barAnnotations = self.mapView.addMKAnnotations(forBars: self.barsViewModel.currentBars)
		}
	}
	
	func updateCollectionViewUI() {
		DispatchQueue.main.async {
			self.collectionView.reloadData()
			self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
		}
	}
	
	@objc func openSearchUI() {
		let searchView = SearchView()
		searchView.modalPresentationStyle = .overCurrentContext
		searchView.modalPresentationCapturesStatusBarAppearance = true
		searchView.barsViewModel = barsViewModel
		searchView.searchBarReceiver = self
		present(searchView, animated: false)
	}
	@objc func promptRemoveDrawUI() {
		let ac = UIAlertController(title: "Are you sure you want to discard your drawings?", message: nil, preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		ac.addAction(UIAlertAction(title: "Discard Drawings", style: .destructive, handler: { [weak self] _ in
			self?.drawMode = false
			self?.mapView.removeMKPolygons()
			self?.clearDrawView.removeFromSuperview()
			self?.barsViewModel.setFilter { business in
				self!.mapView.visibleMapRect.contain(latitude: business.coordinates?.latitude, longitude: business.coordinates?.longitude)
			}
			self?.polygons.removeAll()
		}))
		present(ac, animated: true)
	}
	
	// NAVIGATE USER TO DRAW MODE
	@objc func openDrawUI() {
		let vc = DrawMapViewController()
		vc.region = mapView.region
		vc.drawingMapDelegate = self
		let nav = UINavigationController(rootViewController: vc)
		nav.modalTransitionStyle = .flipHorizontal
		nav.modalPresentationStyle = .fullScreen
		present(nav, animated: true)
	}
	@objc func openListViewUI() {
		tabBarController?.selectedIndex = 1
	}
	func sendSearchBarText(_ text: String) {
		print("Received in MapViewController: ", text)
	}

	/// Adds an array of MKPolygon objects to the map view
	func addMKPolygons(polygons: [MKPolygon]) {
		// Instantiate clear button
		view.addSubview(clearDrawView)
		constrain(clearDrawView) { view in
			let superview = view.superview!.safeAreaLayoutGuide
			view.top == superview.top + 5
			view.right == superview.right - 5
			view.left == superview.left + 5
			view.height == 50
		}
		self.polygons = polygons
		
		
		barsViewModel.setFilter { business in
			polygons.contains { polygon in
				if let lat = business.coordinates?.latitude, let long = business.coordinates?.longitude {
					return polygon.contain(coor: CLLocationCoordinate2D(latitude: lat, longitude: long))
				} else {
					return false
				}
			}
		}
		drawMode = true
		mapView.addOverlays(polygons)
		barsViewModel.removeAllCurrentBars()
		barsViewModel.fetchBarsAtPolygons(polygons)
	}
	@objc func setMapToCurrentLocation() {
		if let coordinate = barsViewModel.fetchUserLocationCoordinate() {
			let coordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: LOCATION_ZOOM_LEVEL, longitudeDelta: LOCATION_ZOOM_LEVEL))
			mapView.setRegion(coordinateRegion, animated: true)
		} else {
			let ac = UIAlertController(title: "Access Restricted", message: "App doesn't have permission to use your location", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		}
	}
}
// MAPVIEW METHODS
extension MapViewController: MKMapViewDelegate {
	#warning("Should actually search for bars but keep in mind the overlays. So don't search for bars in those overlays. This could be a parameter that can be nil in the case you don't need to search within an overlay ")
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		collectionView.hide()
		searchResultView.isHidden = false
		if !drawMode{
			barsViewModel.fetchBarsAtCoordinate(mapView.centerCoordinate)
			barsViewModel.removeAllCurrentBars()
		}
	}
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard let annotation = annotation as? BarMKAnnotation else { return nil }
		let annotationView: CustomAnnotationView
		if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? CustomAnnotationView {
			annotationView = existingView
		} else {
			annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
		}
		#warning("Implement a unique identifier image for annotation view - maybe glass fills up based on stars?")
		annotationView.glyphImage = annotation.image
		annotationView.canShowCallout = true
		return annotationView
	}
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let annotation = view.annotation as? BarMKAnnotation else { return }
		guard let index = self.barsViewModel.currentBars.firstIndex(where: { cdYelpBusiness in
			cdYelpBusiness.id == annotation.id
		}) else { return }
		collectionView.show()
		searchResultView.isHidden = true
		collectionView.animateToItem(at: IndexPath(item: index, section: 0))
	}
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is MKPolygon {
			print("in here")
			let polygonView = MKPolygonRenderer(overlay: overlay)
			polygonView.strokeColor = DEFAULT_TINT?.resolvedColor(with: self.traitCollection)
			polygonView.lineWidth = 5
			polygonView.fillColor = .lightGray.withAlphaComponent(0.3)
			
			return polygonView
		}
		return MKPolylineRenderer(overlay: overlay)
	}
}
