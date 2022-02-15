//
//  Business.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/14/22.
//

import UIKit

class Business: Codable {
	var name: String
	var location: String
	
	init(name: String, location: String) {
		self.name = name
		self.location = location
	}
}
