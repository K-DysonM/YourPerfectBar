//
//  LocationServiceProtocol.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/15/22.
//

import Foundation
import CoreLocation

protocol LocationServiceProtocol {
	var locationManager: CLLocationManager { get set }
	var location: CLLocation? { get }
}


class LocationServicer: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
	var location: CLLocation?
	var locationManager: CLLocationManager
	
	override init() {
		locationManager = CLLocationManager()
		super.init()
		locationManager.delegate = self
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if manager.authorizationStatus == .authorizedAlways {
			self.location = manager.location
		} else if manager.authorizationStatus == .authorizedWhenInUse {
			self.location = manager.location
		}
	}
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		location = locations.last
	}
	func requestLocation(){
		locationManager.requestAlwaysAuthorization()
	}
	
}
