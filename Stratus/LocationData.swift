//
//  LocationData.swift
//  Stratus
//
//  Created by Rudy Bermudez on 7/1/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class Location: Object {
	dynamic var coordinates: Coordinate?
	dynamic var city: String = ""
	dynamic var state: String = ""
	
	convenience init(coordinate: CLLocationCoordinate2D, city: String, state: String) {
		self.init()
		self.coordinates = Coordinate(coordinate)
		self.city = city
		self.state = state
	}
	
	
	override var description: String {
		return "\(city), \(state)"
	}
	
}

class Coordinate: Object {
	dynamic var latitude: Double = 0.0
	dynamic var longitude: Double = 0.0
	
	convenience init(latitude: Double, longitude: Double) {
		self.init()
		self.latitude = latitude
		self.longitude = longitude
	}
	
	convenience init(_ coordinate: CLLocationCoordinate2D) {
		self.init()
		self.latitude = coordinate.latitude
		self.longitude = coordinate.longitude
	}
}
