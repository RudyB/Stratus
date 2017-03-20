//
//  HourlyWeather.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/23/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit
import RealmSwift

class HourlyWeather: Object {
	
	dynamic var temperature: Double = 0.0
	dynamic var humidity: Double = 0.0
	dynamic var precipitationProbability: Double = 0.0
	dynamic var summary: String = ""
	dynamic var iconString: String = ""
	dynamic var time: Double = 0.0
	
	convenience init(temperature: Double, humidity: Double, precipitationProbability: Double, summary: String, iconString: String, time: Double) {
		self.init()
		self.temperature = temperature
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.iconString = iconString
		self.time = time
	}
	
	convenience required init?(JSON: [String : AnyObject]) {
		self.init()
		guard let temperature = JSON["temperature"] as? Double,
			let humidity = JSON["humidity"] as? Double,
			let precipitationProbability = JSON["precipProbability"] as? Double,
			let summary = JSON["summary"] as? String,
			let time = JSON["time"] as? Double,
			let iconString = JSON["icon"] as? String else {
				return nil
		}
		
		self.temperature = temperature
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.iconString = iconString
		self.time = time
	}
}

extension HourlyWeather {
	var temperatureString: String {
		return "\(Int(temperature))º"
	}
	var humidityString: String {
		let percentageValue = Int(humidity * 100)
		return "\(percentageValue)%"
	}
	var precipitationProbabilityString: String {
		let percentageValue = Int(precipitationProbability * 100)
		return "\(percentageValue)%"
	}
	var timeString: String {
		let date = Date(timeIntervalSince1970: time)
		
		let dayTimePeriodFormatter = DateFormatter()
		dayTimePeriodFormatter.dateFormat = "h a"
		return dayTimePeriodFormatter.string(from: date)
	}
	var icon : UIImage {
		return WeatherIcon(rawValue: iconString).image
	}
}
