//
//  DrawMapViewController.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/31/22.
// In charge of the drawing feature added to map

import UIKit
import MapKit
import Cartography

class DrawMapViewController: UIViewController {
	var drawingMapDelegate: DrawingMapDelegate?
	
	// Map
	var mapView: MKMapView!
	var button: UIButton!
	var region: MKCoordinateRegion?
	
	// Drawing
	var bezierPath: UIBezierPath?
	var layer: CALayer?
	
	// DRAWING VARIABLES
	private var currentPath = UIBezierPath()
	private var currentLayer = CAShapeLayer()
	var points = [CLLocationCoordinate2D]()
	var lastPoint = CGPoint.zero
	var firstPoint = CGPoint.zero
	var drawingLayers: [CAShapeLayer] = []
	var polygons: [MKPolygon] = [] {
		didSet {
			if points.isEmpty {
				button.setTitle("DRAW MODE", for: .normal)
				button.setTitleColor(.label, for: .normal)
				button.isUserInteractionEnabled = false
				toolbarItems?[2].tintColor = .white.withAlphaComponent(0.5)
				toolbarItems?[2].target = nil
			} else {
				button.setTitle("RESET", for: .normal)
				button.setTitleColor(.yellow, for: .normal)
				button.isUserInteractionEnabled = true
				toolbarItems?[2].tintColor = .white
				toolbarItems?[2].target = self
			}
		}
	}
	var group1: ConstraintGroup?
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .black
		mapView = MKMapView()
		mapView.isUserInteractionEnabled = false
		view.addSubview(mapView)
		
		button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
		button.backgroundColor = .black
		button.setTitle("DRAW MODE", for: .normal)
		button.addTarget(self, action: #selector(clearDrawings), for: .touchDown)
		view.addSubview(button)
		
		group1 = constrain(mapView, button) { mapView, button in
			let superview = mapView.superview!.safeAreaLayoutGuide
			button.top == superview.top
			button.left == superview.left
			button.right == superview.right
			button.height == 44
			
			mapView.top == button.bottom
			mapView.left == superview.left
			mapView.right == superview.right
			mapView.bottom == superview.bottom
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()

		guard let region = region else { dismiss(animated: false); return }
		mapView.setRegion(region, animated: true)
		
		modalPresentationCapturesStatusBarAppearance = true
		
		// TOOL BAR
		let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissUI))
		cancelButton.tintColor = .white
		let add = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(applySearch))
		add.tintColor = .white.withAlphaComponent(0.5)
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		toolbarItems = [cancelButton, spacer, add]
		
		
		navigationController?.toolbar.isTranslucent = false
		navigationController?.toolbar.barTintColor = .black
		
		navigationController?.setNavigationBarHidden(true, animated: true)
		navigationController?.setToolbarHidden(false, animated: false)
		
		
	}
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	override var prefersStatusBarHidden: Bool {
		return false
	}

	
	@objc func dismissUI() {
		self.dismiss(animated: true)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		// Initialized for new drawing
		lastPoint = touch.location(in: view)
		firstPoint = lastPoint
		currentLayer = CAShapeLayer()
		currentPath = UIBezierPath()
		points = []
		drawingLayers.append(currentLayer)
		view.layer.addSublayer(currentLayer)
	}
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let currentPoint = touch.location(in: view)
		drawLine(from: lastPoint, to: currentPoint)
		let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
		points.append(coordinate)
		lastPoint = currentPoint
	}
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Close the drawing path by connecting the end to the beginning
		currentPath.addLine(to: firstPoint)
		currentLayer.path = currentPath.cgPath
		let polygon = MKPolygon(coordinates: &points, count: points.count)
		polygons.append(polygon)
	}
	func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
		currentPath.move(to: fromPoint)
		currentPath.addLine(to: toPoint)
		currentLayer.strokeColor = DEFAULT_TINT?.withAlphaComponent(0.7).cgColor
		currentLayer.fillColor = nil
		currentLayer.lineWidth = 5.0
		currentLayer.lineCap = .round
		currentLayer.lineJoin = .round
		currentLayer.path = currentPath.cgPath
	}
	
	@objc func applySearch() {
		guard !polygons.isEmpty else { return }
		guard let delegate = drawingMapDelegate else { return }
		delegate.addMKPolygons(polygons: polygons)
		self.dismiss(animated: true)
	}
	
	@objc func clearDrawings() {
		for layer in drawingLayers {
			layer.removeFromSuperlayer()
		}
		points.removeAll(keepingCapacity: true)
		drawingLayers.removeAll(keepingCapacity: true)
		polygons.removeAll(keepingCapacity: true)
	}
	
}
