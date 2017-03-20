//
//  CurrentWeather.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/21/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit
import RealmSwift

class CurrentWeather: Object, JSONDecodable {
	dynamic var temperature: Double = 0.0
	dynamic var apparentTemperature: Double = 0.0
	dynamic var humidity: Double = 0.0
	dynamic var precipitationProbability: Double = 0.0
	dynamic var summary: String = ""
	dynamic var windSpeed: Double = 0.0
	dynamic var cloudCover: Double = 0.0
	dynamic var iconString: String = ""
	dynamic var visibility: Double = 0.0
	
	convenience init(temperature: Double, apparentTemperature: Double, humidity: Double, precipitationProbability: Double, summary:String, windSpeed: Double, cloudCover: Double, iconString: String, visibility: Double){
		self.init()
		self.temperature = temperature
		self.apparentTemperature = apparentTemperature
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.windSpeed = windSpeed
		self.cloudCover = cloudCover
		self.iconString = iconString
		self.visibility = visibility
	}
	
	convenience required init?(JSON: [String : AnyObject]) {
		self.init()
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
		
		self.temperature = temperature
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.iconString = iconString
		// TODO: Make computed properties
		self.apparentTemperature = apparentTemperature
		self.windSpeed = windSpeed
		self.cloudCover = cloudCover
		self.visibility = visibility
	}
	
}



extension CurrentWeather {
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
	var icon : UIImage {
		return WeatherIcon(rawValue: iconString).image
	}
}
