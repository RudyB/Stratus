//
//  LocationData.swift
//  Stratus
//
//  Created by Rudy Bermudez on 7/1/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import Foundation
import CoreLocation

class LocationData: NSObject{
	let coordinates: CLLocationCoordinate2D?
	var city: String?
	var state: String?
	var currentWeather: CurrentWeather?
	let useLocationServices: Bool
	
	init(coordinates: CLLocationCoordinate2D, city: String, state: String){
		self.coordinates = coordinates
		self.city = city
		self.state = state
		self.useLocationServices = false
		self.currentWeather = nil
	}
	
	init(useLocationServices: Bool){
		self.useLocationServices = true
		self.city = nil
		self.coordinates = nil
		self.state = nil
		self.currentWeather = nil
	}
	
	required init(coder aDecoder: NSCoder) {
		let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double
		let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double
		if let latitude = latitude, let longitude = longitude {
			self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		} else {
			self.coordinates = nil
		}
		self.city = aDecoder.decodeObject(forKey: "city") as? String
		self.state = aDecoder.decodeObject(forKey: "state") as? String
		self.currentWeather = aDecoder.decodeObject(forKey: "currentWeather") as? CurrentWeather
		self.useLocationServices = aDecoder.decodeBool(forKey: "useLocationServices")
	}
	
	func encodeWithCoder(_ aCoder: NSCoder!) {
		let latitude = coordinates?.latitude as Double?
		let longitude = coordinates?.longitude as Double?
		aCoder.encode(latitude, forKey: "latitude")
		aCoder.encode(longitude, forKey: "longitude")
		aCoder.encode(city, forKey: "city")
		aCoder.encode(state, forKey: "state")
		aCoder.encode(currentWeather, forKey: "currentWeather")
		aCoder.encode(useLocationServices, forKey: "useLocationServices")
	}
	
	var prettyLocationName: String? {
		if let city = city, let state = state {
			return "\(city), \(state)"
		}
		return nil
	}
}
