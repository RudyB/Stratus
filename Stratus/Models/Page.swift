//
//  Page.swift
//  Stratus
//
//  Created by Rudy Bermudez on 3/21/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import Foundation

class Page: NSObject {
	var location: Location?
	var weatherData: WeatherData?
	var currentWeather: CurrentWeather?
	var usesLocationServices: Bool? = false
	
	init(location: Location?, weatherData: WeatherData? = nil, usesLocationServices: Bool = false) {
		self.location = location
		self.weatherData = weatherData
		self.usesLocationServices = usesLocationServices
	}
	
	required init(coder aDecoder: NSCoder) {
		self.location = aDecoder.decodeObject(forKey: "location") as? Location
		self.weatherData = aDecoder.decodeObject(forKey: "weatherData") as? WeatherData
		self.currentWeather = aDecoder.decodeObject(forKey: "currentWeather") as? CurrentWeather
		self.usesLocationServices = aDecoder.decodeObject(forKey: "usesLocationServices") as? Bool
	}
	
	func encodeWithCoder(_ aCoder: NSCoder!) {
		aCoder.encode(location, forKey: "location")
		aCoder.encode(weatherData, forKey: "weatherData")
		aCoder.encode(currentWeather, forKey: "currentWeather")
		aCoder.encode(usesLocationServices, forKey: "usesLocationServices")
	}
	
	convenience init(usesLocationServices: Bool = true) {
		self.init(location: nil, weatherData: nil, usesLocationServices: usesLocationServices)
	}
}
