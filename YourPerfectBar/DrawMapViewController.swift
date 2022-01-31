//
//  DrawMapViewController.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/31/22.
// In charge of the drawing feature added to map

import UIKit
import MapKit

class DrawMapViewController: UIViewController {
	
	// Map
	var mapView: MKMapView!
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
	var polygons: [MKPolygon] = []
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		navigationItem.title = "DRAW MODE"
		let xButton = UIBarButtonItem(image: UIImage(systemName: "x.square")?.withTintColor(.red), style: .plain, target: self, action: #selector(clearDrawings))
		let checkButton = UIBarButtonItem(image: UIImage(systemName: "checkmark.square")?.withTintColor(.green), style: .plain, target: self, action: #selector(applySearch))
		navigationItem.setRightBarButtonItems([checkButton, xButton], animated: false)
		mapView = MKMapView()
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.isUserInteractionEnabled = false
		view.addSubview(mapView)
		NSLayoutConstraint.activate(
			[
				mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
				mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
				mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
				mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
			]
		)
		guard let region = region else { return dismiss(animated: false) {
			print("INVALID INITIALIZATION")
		} }
		mapView.setRegion(region, animated: true)
		let ac = UIAlertController(title: "Entering Draw Mode", message: "Draw a shape around an area to search", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Start", style: .default))
		present(ac, animated: true)
		
		// Do any additional setup after loading the view.
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
		currentLayer.strokeColor = UIColor(named: "HunterGreen")?.withAlphaComponent(0.7).cgColor
		currentLayer.fillColor = nil
		currentLayer.lineWidth = 5.0
		currentLayer.lineCap = .round
		currentLayer.lineJoin = .round
		currentLayer.path = currentPath.cgPath
	}
	
	@objc func applySearch() {
		guard let currentIndex = navigationController?.viewControllers.count else { navigationController?.popViewController(animated: true); return }
		// Getting the view controller below this in the stack
		if let present = navigationController?.viewControllers[currentIndex-2] as? MapViewController {
			present.presentMKPolygons(polygons: polygons)
		}
		navigationController?.popViewController(animated: true)
	}
	
	@objc func clearDrawings() {
		for layer in drawingLayers {
			layer.removeFromSuperlayer()
		}
		drawingLayers.removeAll(keepingCapacity: true)
		polygons.removeAll(keepingCapacity: true)
	}
	
}
