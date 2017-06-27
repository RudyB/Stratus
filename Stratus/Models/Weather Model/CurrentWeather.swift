//
//  CurrentWeather.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/21/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit

struct CurrentWeather: Codable, JSONDecodable {
	let temperature: Double
	let apparentTemperature: Double
	let humidity: Double
	let precipitationProbability: Double
	let summary: String
	let windSpeed: Double
	let cloudCover: Double
	let icon: WeatherIcon
	let visibility: Double
	
    init?(JSON: [String : AnyObject]) {
		guard let temperature = JSON["temperature"] as? Double,
			let apparentTemperature = JSON["apparentTemperature"] as? Double,
			let windSpeed = JSON["windSpeed"] as? Double,
			let cloudCover = JSON["cloudCover"] as? Double,
			let visibility = JSON["visibility"] as? Double,
			let humidity = JSON["humidity"] as? Double,
			let precipitationProbability = JSON["precipProbability"] as? Double,
			let summary = JSON["summary"] as? String,
			let iconString = JSON["icon"] as? String else {
				return nil
		}
		
        self.icon = WeatherIcon(rawValue: iconString)
		self.temperature = temperature
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		// TODO: Make computed properties
		self.apparentTemperature = apparentTemperature
		self.windSpeed = windSpeed
		self.cloudCover = cloudCover
		self.visibility = visibility
	}
	
    
}



extension CurrentWeather: Weather {
    
	var temperatureString: String {
		return "\(Int(temperature))º"
	}
	var apparentTemperatureString: String {
		return "\(Int(apparentTemperature))º"
	}
	var humidityString: String {
		let percentageValue = Int(humidity * 100)
		return "\(percentageValue)%"
	}
	var precipitationProbabilityString: String {
		let percentageValue = Int(precipitationProbability * 100)
		return "\(percentageValue)%"
	}
	var windSpeedString: String {
		return "\(Int(windSpeed)) MPH"
	}
	var cloudCoverString: String {
		let percentageValue = Int(cloudCover * 100)
		return "\(percentageValue)%"
	}
	var visibilityString: String {
		return "\(Int(visibility)) MI"
	}
}
