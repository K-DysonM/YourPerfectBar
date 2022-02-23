//
//  SearchBarReceiverProtocol.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/12/22.
//

import UIKit
import MapKit

protocol SearchBarReceiverProtocol {
	func sendSearchBarText(_ text: String)
	var mapView: BarsMapView! { get }
}

protocol DrawingMapDelegate {
	func addMKPolygons(polygons: [MKPolygon])
}
