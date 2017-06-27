//
//  LocationData.swift
//  Stratus
//
//  Created by Rudy Bermudez on 7/1/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import Foundation
import CoreLocation


struct Location: Codable{
	let coordinates: Coordinate?
	var city: String?
	var state: String?
    
	var prettyLocationName: String? {
		if let city = city, let state = state {
			return "\(city), \(state)"
		}
		return nil
	}
}

struct Coordinate: Codable {
	let latitude: Double
	let longitude: Double
	
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(_ coordinate: CLLocationCoordinate2D) {
		self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}
}
