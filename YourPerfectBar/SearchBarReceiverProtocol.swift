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
	func sendSearchBarAutocompleteResults(_ places: [Business])
	var mapView: BarsMapView! { get }
}
