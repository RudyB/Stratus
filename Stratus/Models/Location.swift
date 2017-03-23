//
//  LocationData.swift
//  Stratus
//
//  Created by Rudy Bermudez on 7/1/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import Foundation
import CoreLocation


class Location: NSObject{
	let coordinates: Coordinate?
	var city: String?
	var state: String?
	
	init(coordinates: Coordinate, city: String, state: String){
		self.coordinates = coordinates
		self.city = city
		self.state = state
	}
	
	
	required init(coder aDecoder: NSCoder) {
		let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double
		let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double
		if let latitude = latitude, let longitude = longitude {
			self.coordinates = Coordinate(latitude: latitude, longitude: longitude)
		} else {
			self.coordinates = nil
		}
		self.city = aDecoder.decodeObject(forKey: "city") as? String
		self.state = aDecoder.decodeObject(forKey: "state") as? String
	}
	
	func encodeWithCoder(_ aCoder: NSCoder!) {
		let latitude = coordinates?.latitude as Double?
		let longitude = coordinates?.longitude as Double?
		aCoder.encode(latitude, forKey: "latitude")
		aCoder.encode(longitude, forKey: "longitude")
		aCoder.encode(city, forKey: "city")
		aCoder.encode(state, forKey: "state")
	}
	

	
	var prettyLocationName: String? {
		if let city = city, let state = state {
			return "\(city), \(state)"
		}
		return nil
	}
}

class Coordinate: NSObject {
	let latitude: Double
	let longitude: Double
	
	init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
	
	convenience init(_ coordinate: CLLocationCoordinate2D) {
		self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}
}
