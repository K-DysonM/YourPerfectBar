//
//  BarAnnotationView.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/5/22.
//

import UIKit
import MapKit

class CustomAnnotationView: MKMarkerAnnotationView {
	static let glyphImage: UIImage = {
		let rect = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
		return UIGraphicsImageRenderer(bounds: rect).image { _ in
			let radius: CGFloat = 11
			let offset: CGFloat = 7
			let insetY: CGFloat = 5
			let center = CGPoint(x: rect.midX, y: rect.maxY - radius - insetY)
			let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi, clockwise: true)
			path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY + insetY), controlPoint: CGPoint(x: rect.midX - radius, y: center.y - offset))
			path.addQuadCurve(to: CGPoint(x: rect.midX + radius, y: center.y), controlPoint: CGPoint(x: rect.midX + radius, y: center.y - offset))
			path.close()
			UIColor.white.setFill()
			path.fill()
		}
	}()
	
	override var annotation: MKAnnotation? {
		didSet { configure(for: annotation) }
	}
	
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		configure(for: annotation)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(for annotation: MKAnnotation?) {
		displayPriority = .required
		
		// if doing clustering, also add
		// clusteringIdentifier = ...
	}
}
