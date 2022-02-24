//
//  HomeViewController.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/24/22.
//

import UIKit
import Cartography

class HomeViewController: UIViewController, UISearchBarDelegate {
	let customFont = UIFont(name: "QwitcherGrypen-Regular", size: 36)

	var skylineView: UIView!
	var searchBar: UISearchBar!
	var label: UILabel!
	var image: UIImageView!
	var shapeLayer = CAShapeLayer()
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .systemBackground
		
		searchBar = UISearchBar()
		searchBar.placeholder = "Search"
		
		label = UILabel()
		label.text = "What are the plans for tonight?"
		label.font = customFont
		label.textAlignment = .center
		
		image = UIImageView(image: UIImage(named: "logo"))
		image.backgroundColor = .clear
		
		skylineView = UIView()
		skylineView.backgroundColor = .systemBackground
		
		
		[label, searchBar, image, skylineView].forEach {
			view.addSubview($0)
		}
		view.sendSubviewToBack(skylineView)
		
		constrain(label, searchBar, image, skylineView) { (label, searchBar, image, skylineView) in
			let superview = label.superview!.safeAreaLayoutGuide
			align(left: superview, searchBar, label, skylineView)
			align(right: superview, searchBar, label, skylineView)
			image.bottom == superview.centerY
			image.centerX == superview.centerX
			image.width == 75
			image.height == 75
			label.top == image.bottom + 8
			searchBar.top == label.bottom + 8
			
			skylineView.top == superview.top
			skylineView.bottom == image.top
		}
		
	}
	override func viewDidLayoutSubviews() {
		print(skylineView.frame)
		print(image.frame)
		animateSkyline()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		shapeLayer.strokeColor = UIColor.yellow.cgColor
		shapeLayer.lineWidth = 1.0
		shapeLayer.lineCap = CAShapeLayerLineCap.round
		skylineView.layer.addSublayer(shapeLayer)
		
		searchBar.delegate = self
		searchBar.showsCancelButton = true
    }
	#warning("Whats the difference between = {} and just {} ...? when i do = {} i cant access any variables why?")
	var skyline: UIBezierPath {
		let bezierPath = UIBezierPath()
		// get bottom left of uiview
		let bottomLeft = skylineView.frame.origin.y + skylineView.frame.height/2
		bezierPath.move(to: CGPoint(x: 0.5, y: 59.5))
		bezierPath.addLine(to: CGPoint(x: 4.5, y: 59.5))
		bezierPath.addLine(to: CGPoint(x: 4.5, y: 70.5))
		bezierPath.addLine(to: CGPoint(x: 6.5, y: 68.5))
		bezierPath.addLine(to: CGPoint(x: 6.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 11.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 11.5, y: 50.5))
		bezierPath.addLine(to: CGPoint(x: 12.5, y: 50.5))
		bezierPath.addLine(to: CGPoint(x: 12.5, y: 47.5))
		bezierPath.addLine(to: CGPoint(x: 20.5, y: 47.5))
		bezierPath.addLine(to: CGPoint(x: 20.5, y: 50.5))
		bezierPath.addLine(to: CGPoint(x: 22.5, y: 50.5))
		bezierPath.addLine(to: CGPoint(x: 22.5, y: 65.5))
		bezierPath.addCurve(to: CGPoint(x: 26.5, y: 65.5), controlPoint1: CGPoint(x: 22.5, y: 65.5), controlPoint2: CGPoint(x: 26.5, y: 66.5))
		bezierPath.addCurve(to: CGPoint(x: 26.5, y: 59.5), controlPoint1: CGPoint(x: 26.5, y: 64.5), controlPoint2: CGPoint(x: 26.5, y: 59.5))
		bezierPath.addLine(to: CGPoint(x: 27.5, y: 58.5))
		bezierPath.addLine(to: CGPoint(x: 31.5, y: 58.5))
		bezierPath.addLine(to: CGPoint(x: 32.5, y: 59.5))
		bezierPath.addLine(to: CGPoint(x: 32.5, y: 72.5))
		bezierPath.addLine(to: CGPoint(x: 33.5, y: 72.5))
		bezierPath.addLine(to: CGPoint(x: 33.5, y: 67.5))
		bezierPath.addLine(to: CGPoint(x: 34.5, y: 67.5))
		bezierPath.addLine(to: CGPoint(x: 34.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 35.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 35.5, y: 67.5))
		bezierPath.addLine(to: CGPoint(x: 36.5, y: 67.5))
		bezierPath.addLine(to: CGPoint(x: 36.5, y: 42.5))
		bezierPath.addLine(to: CGPoint(x: 40.5, y: 38.5))
		bezierPath.addLine(to: CGPoint(x: 44.5, y: 42.5))
		bezierPath.addLine(to: CGPoint(x: 45.5, y: 41.5))
		bezierPath.addLine(to: CGPoint(x: 45.5, y: 36.5))
		bezierPath.addLine(to: CGPoint(x: 49.5, y: 32.5))
		bezierPath.addLine(to: CGPoint(x: 53.5, y: 36.5))
		bezierPath.addLine(to: CGPoint(x: 53.5, y: 41.5))
		bezierPath.addLine(to: CGPoint(x: 54.5, y: 42.5))
		bezierPath.addLine(to: CGPoint(x: 55.5, y: 42.5))
		bezierPath.addLine(to: CGPoint(x: 55.5, y: 67.5))
		bezierPath.addLine(to: CGPoint(x: 57.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 57.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 64.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 64.5, y: 51.5))
		bezierPath.addLine(to: CGPoint(x: 66.5, y: 52.5))
		bezierPath.addLine(to: CGPoint(x: 66.5, y: 62.5))
		bezierPath.addLine(to: CGPoint(x: 68.5, y: 62.5))
		bezierPath.addLine(to: CGPoint(x: 68.5, y: 72.5))
		bezierPath.addLine(to: CGPoint(x: 69.5, y: 72.5))
		bezierPath.addLine(to: CGPoint(x: 69.5, y: 70.5))
		bezierPath.addLine(to: CGPoint(x: 71.5, y: 70.5))
		bezierPath.addLine(to: CGPoint(x: 71.5, y: 72.5))
		bezierPath.addLine(to: CGPoint(x: 72.5, y: 72.5))
		bezierPath.addLine(to: CGPoint(x: 72.5, y: 59.5))
		bezierPath.addLine(to: CGPoint(x: 73.5, y: 58.5))
		bezierPath.addLine(to: CGPoint(x: 73.5, y: 50.5))
		bezierPath.addLine(to: CGPoint(x: 75.5, y: 47.5))
		bezierPath.addLine(to: CGPoint(x: 75.5, y: 35.5))
		bezierPath.addLine(to: CGPoint(x: 75.5, y: 47.5))
		bezierPath.addLine(to: CGPoint(x: 77.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 79.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 79.5, y: 18.5))
		bezierPath.addLine(to: CGPoint(x: 81.5, y: 16.5))
		bezierPath.addLine(to: CGPoint(x: 84.5, y: 16.5))
		bezierPath.addLine(to: CGPoint(x: 84.5, y: 14.5))
		bezierPath.addLine(to: CGPoint(x: 86.5, y: 13.5))
		bezierPath.addLine(to: CGPoint(x: 86.5, y: 8.5))
		bezierPath.addLine(to: CGPoint(x: 87.5, y: 7.5))
		bezierPath.addLine(to: CGPoint(x: 87.5, y: 0.5))
		bezierPath.addLine(to: CGPoint(x: 88.5, y: 0.5))
		bezierPath.addLine(to: CGPoint(x: 88.5, y: 7.5))
		bezierPath.addLine(to: CGPoint(x: 89.5, y: 8.5))
		bezierPath.addLine(to: CGPoint(x: 89.5, y: 13.5))
		bezierPath.addLine(to: CGPoint(x: 91.5, y: 14.5))
		bezierPath.addLine(to: CGPoint(x: 91.5, y: 16.5))
		bezierPath.addLine(to: CGPoint(x: 94.5, y: 16.5))
		bezierPath.addLine(to: CGPoint(x: 96.5, y: 18.5))
		bezierPath.addLine(to: CGPoint(x: 96.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 98.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 98.5, y: 52.5))
		bezierPath.addLine(to: CGPoint(x: 106.5, y: 52.5))
		bezierPath.addLine(to: CGPoint(x: 106.5, y: 74.5))
		bezierPath.addLine(to: CGPoint(x: 110.5, y: 74.5))
		bezierPath.addLine(to: CGPoint(x: 110.5, y: 42.5))
		bezierPath.addLine(to: CGPoint(x: 113.5, y: 42.5))
		bezierPath.addLine(to: CGPoint(x: 116.5, y: 41.5))
		bezierPath.addLine(to: CGPoint(x: 118.5, y: 42.5))
		bezierPath.addLine(to: CGPoint(x: 121.5, y: 42.5))
		bezierPath.addLine(to: CGPoint(x: 121.5, y: 59.5))
		bezierPath.addLine(to: CGPoint(x: 121.5, y: 55.5))
		bezierPath.addLine(to: CGPoint(x: 125.5, y: 55.5))
		bezierPath.addLine(to: CGPoint(x: 125.5, y: 58.5))
		bezierPath.addLine(to: CGPoint(x: 125.5, y: 51.5))
		bezierPath.addLine(to: CGPoint(x: 127.5, y: 50.5))
		bezierPath.addLine(to: CGPoint(x: 130.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 133.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 136.5, y: 50.5))
		bezierPath.addLine(to: CGPoint(x: 138.5, y: 51.5))
		bezierPath.addLine(to: CGPoint(x: 138.5, y: 59.5))
		bezierPath.addLine(to: CGPoint(x: 141.5, y: 62.5))
		bezierPath.addLine(to: CGPoint(x: 143.5, y: 62.5))
		bezierPath.addLine(to: CGPoint(x: 145.5, y: 62.5))
		bezierPath.addLine(to: CGPoint(x: 145.5, y: 35.5))
		bezierPath.addLine(to: CGPoint(x: 157.5, y: 35.5))
		bezierPath.addLine(to: CGPoint(x: 157.5, y: 70.5))
		bezierPath.addLine(to: CGPoint(x: 157.5, y: 72.5))
		bezierPath.addLine(to: CGPoint(x: 159.5, y: 70.5))
		bezierPath.addLine(to: CGPoint(x: 161.5, y: 70.5))
		bezierPath.addLine(to: CGPoint(x: 161.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 163.5, y: 63.5))
		bezierPath.addLine(to: CGPoint(x: 165.5, y: 63.5))
		bezierPath.addLine(to: CGPoint(x: 165.5, y: 63.5))
		bezierPath.addLine(to: CGPoint(x: 167.5, y: 62.5))
		bezierPath.addLine(to: CGPoint(x: 167.5, y: 59.5))
		bezierPath.addLine(to: CGPoint(x: 173.5, y: 59.5))
		bezierPath.addLine(to: CGPoint(x: 175.5, y: 62.5))
		bezierPath.addLine(to: CGPoint(x: 175.5, y: 58.5))
		bezierPath.addLine(to: CGPoint(x: 177.5, y: 56.5))
		bezierPath.addLine(to: CGPoint(x: 177.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 182.5, y: 45.5))
		bezierPath.addLine(to: CGPoint(x: 182.5, y: 41.5))
		bezierPath.addLine(to: CGPoint(x: 182.5, y: 45.5))
		bezierPath.addLine(to: CGPoint(x: 186.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 186.5, y: 56.5))
		bezierPath.addLine(to: CGPoint(x: 187.5, y: 56.5))
		bezierPath.addLine(to: CGPoint(x: 187.5, y: 52.5))
		bezierPath.addLine(to: CGPoint(x: 192.5, y: 52.5))
		bezierPath.addLine(to: CGPoint(x: 192.5, y: 29.5))
		bezierPath.addLine(to: CGPoint(x: 206.5, y: 29.5))
		bezierPath.addLine(to: CGPoint(x: 206.5, y: 70.5))
		bezierPath.addLine(to: CGPoint(x: 207.5, y: 68.5))
		bezierPath.addLine(to: CGPoint(x: 210.5, y: 68.5))
		bezierPath.addLine(to: CGPoint(x: 211.5, y: 70.5))
		bezierPath.addLine(to: CGPoint(x: 211.5, y: 52.5))
		bezierPath.addLine(to: CGPoint(x: 215.5, y: 52.5))
		bezierPath.addLine(to: CGPoint(x: 215.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 219.5, y: 49.5))
		bezierPath.addLine(to: CGPoint(x: 220.5, y: 52.5))
		bezierPath.addLine(to: CGPoint(x: 220.5, y: 35.5))
		bezierPath.addLine(to: CGPoint(x: 222.5, y: 32.5))
		bezierPath.addLine(to: CGPoint(x: 225.5, y: 32.5))
		bezierPath.addLine(to: CGPoint(x: 227.5, y: 35.5))
		bezierPath.addLine(to: CGPoint(x: 227.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 230.5, y: 65.5))
		bezierPath.addLine(to: CGPoint(x: 230.5, y: 47.5))
		bezierPath.addLine(to: CGPoint(x: 235.5, y: 47.5))
		bezierPath.addLine(to: CGPoint(x: 237.5, y: 45.5))
		bezierPath.addLine(to: CGPoint(x: 237.5, y: 42.5))
		bezierPath.addLine(to: CGPoint(x: 239.5, y: 42.5))
		return bezierPath
	}
	
	
	// Here we will do the animation for skyline
	func animateSkyline() {
		//// Bezier Drawing
		let bezierPath = skyline
		DEFAULT_TINT?.setStroke()
		bezierPath.lineWidth = 1
		bezierPath.stroke()
		let scale = CGAffineTransform(scaleX: 1.6, y: 1)
		bezierPath.apply(scale)
		// Get bottom left y position of view and set start point to there
		let difference = skylineView.frame.maxY - skylineView.frame.minY - 59.5
		bezierPath.apply(CGAffineTransform(translationX: 0, y: difference))
		shapeLayer.path = bezierPath.cgPath
		
		
		let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
		
		strokeEndAnimation.fromValue = 0.5
		strokeEndAnimation.toValue = 1.0
		strokeEndAnimation.duration = 3.0
		strokeEndAnimation.fillMode = CAMediaTimingFillMode.forwards
		strokeEndAnimation.isRemovedOnCompletion = false
		
		let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
		strokeStartAnimation.fromValue = 0.5
		strokeStartAnimation.toValue = 0.0
		strokeStartAnimation.duration = 3.0
		strokeStartAnimation.fillMode = CAMediaTimingFillMode.backwards
		strokeStartAnimation.isRemovedOnCompletion = false
		
		let animationGroup = CAAnimationGroup()
		animationGroup.animations = [strokeEndAnimation, strokeStartAnimation]
		animationGroup.duration = 3.0
		
		shapeLayer.add(animationGroup, forKey: "drawLineAnimation")
		
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		print("searchBarSearchButtonClicked")
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	

}
