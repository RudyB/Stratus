//
//  Page.swift
//  Stratus
//
//  Created by Rudy Bermudez on 3/21/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import Foundation

class Page: Codable {
	var location: Location?
	var weatherData: WeatherData?
	var currentWeather: CurrentWeather?
	var usesLocationServices: Bool? = false
	
	init(location: Location?, weatherData: WeatherData? = nil, usesLocationServices: Bool = false) {
		self.location = location
		self.weatherData = weatherData
		self.usesLocationServices = usesLocationServices
	}
	
	convenience init(usesLocationServices: Bool = true) {
		self.init(location: nil, weatherData: nil, usesLocationServices: usesLocationServices)
	}
}
