//
//  BarMKAnnotation.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/29/22.
//

import Foundation
import UIKit
import MapKit

public class BarMKAnnotation: NSObject, MKAnnotation {
	
	//Per MKAnnotation Documentation: An object that adopts this protocol must implement the coordinate property. The other methods of this protocol are optional.
	// MARK: - Properties
	public let id: String?
	public let coordinate: CLLocationCoordinate2D
	public let name: String?
	public let rating: Double?
	public let image: UIImage?
	public var title: String? {
		return name
	}
	
	// MARK: - Object Lifecycle
	public init(
		id: String?,
		coordinate: CLLocationCoordinate2D,
		name: String?,
		rating: Double?
	) {
		self.id = id
		self.coordinate = coordinate
		self.name = name
		self.rating = rating
		self.image = "🍻".image()!
		super.init()
	}
}
extension String {
	func image() -> UIImage? {
		let size = CGSize(width: 30, height: 30)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		UIColor.clear.set()
		let rect = CGRect(origin: .zero, size: size)
		UIRectFill(CGRect(origin: .zero, size: size))
		(self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 30)])
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
}
