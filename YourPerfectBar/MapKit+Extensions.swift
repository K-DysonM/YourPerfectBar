//
//  MapKit+Extensions.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/2/22.
//

import Foundation
import MapKit

extension MKPolygon {
	func contain(coor: CLLocationCoordinate2D) -> Bool {
		let polygonRenderer = MKPolygonRenderer(polygon: self)
		let currentMapPoint: MKMapPoint = MKMapPoint(coor)
		let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
		if polygonRenderer.path == nil {
			return false
		} else {
			return polygonRenderer.path.contains(polygonViewPoint)
		}
	}
}
extension MKMapRect {
	func contain(latitude: Double?, longitude: Double?) -> Bool{
		guard let latitude = latitude, let longitude = longitude else { return false }
		let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		return contains(MKMapPoint(coordinate))
	}
}
