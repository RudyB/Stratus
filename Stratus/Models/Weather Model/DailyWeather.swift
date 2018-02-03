//
//  DailyWeather.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/23/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit

struct DailyWeather: Codable, JSONDecodable{
	let temperatureMin: Double
	let temperatureMax: Double
	let humidity: Double
	let precipitationProbability: Double
	let summary: String
	let icon: WeatherIcon
	let date: Double
	let sunriseTime: Double
	let sunsetTime: Double
	var temperature: Double {
		return (temperatureMin + temperatureMax) / 2.0
	}
    
	
	init?(JSON: [String : AnyObject]) {
		guard let temperatureMin = JSON["temperatureMin"] as? Double,
			let temperatureMax = JSON["temperatureMax"] as? Double,
			let humidity = JSON["humidity"] as? Double,
			let precipitationProbability = JSON["precipProbability"] as? Double,
			let summary = JSON["summary"] as? String,
			let date = JSON["time"] as? Double,
			let sunriseTime = JSON["sunriseTime"] as? Double,
			let sunsetTime = JSON["sunsetTime"] as? Double,
			let iconString = JSON["icon"] as? String else {
				return nil
		}
        self.icon = WeatherIcon(rawValue: iconString)
		self.temperatureMin = temperatureMin
		self.temperatureMax = temperatureMax
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.date = date
		self.sunriseTime = sunriseTime
		self.sunsetTime = sunsetTime
	}
    
	
}

extension DailyWeather: Weather {

	var temperatureMinString: String {
		return "\(Int(temperatureMin))º"
	}
	var temperatureMaxString: String {
		return "\(Int(temperatureMax))º"
	}
	var humidityString: String {
		let percentageValue = Int(humidity * 100)
		return "\(percentageValue)%"
	}
	var precipitationProbabilityString: String {
		let percentageValue = Int(precipitationProbability * 100)
		return "\(percentageValue)%"
	}
	var dateString: String {
		let date = Date(timeIntervalSince1970: self.date)
		
		let dayTimePeriodFormatter = DateFormatter()
		dayTimePeriodFormatter.dateFormat = "EEEE"
		
		return dayTimePeriodFormatter.string(from: date)
	}
	var sunriseTimeString: String {
		let sunriseTime = Date(timeIntervalSince1970: self.sunriseTime)
		let dayTimePeriodFormatter = DateFormatter()
		dayTimePeriodFormatter.dateFormat = "h:mm a"
		return dayTimePeriodFormatter.string(from: sunriseTime)
	}
	var sunsetTimeString: String {
		let sunsetTime = Date(timeIntervalSince1970: self.sunsetTime)
		let dayTimePeriodFormatter = DateFormatter()
		dayTimePeriodFormatter.dateFormat = "h:mm a"
		return dayTimePeriodFormatter.string(from: sunsetTime)
	}
	
}
