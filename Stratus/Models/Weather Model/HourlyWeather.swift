//
//  HourlyWeather.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/23/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit

struct HourlyWeather: Codable {
	let temperature: Double
	let humidity: Double
	let precipitationProbability: Double
	let summary: String
	let icon: WeatherIcon
	let time: Double
}

extension HourlyWeather: JSONDecodable, Weather {
	init?(JSON: [String : AnyObject]) {
		guard let temperature = JSON["temperature"] as? Double,
			let humidity = JSON["humidity"] as? Double,
			let precipitationProbability = JSON["precipProbability"] as? Double,
			let summary = JSON["summary"] as? String,
			let time = JSON["time"] as? Double,
			let iconString = JSON["icon"] as? String else {
				return nil
		}
		self.icon = WeatherIcon(rawValue: iconString)
		self.temperature = temperature
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.time = time
	}
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
}

