//
//  DailyWeather.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/23/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit

class DailyWeather: NSObject, JSONDecodable{
	let temperatureMin: Double
	let temperatureMax: Double
	let humidity: Double
	let precipitationProbability: Double
	let summary: String
	let icon: UIImage
	let date: Double
	let sunriseTime: Double
	let sunsetTime: Double
	var temperature: Double {
		return (temperatureMin + temperatureMax) / 2.0
	}
	init(temperatureMin: Double, temperatureMax: Double, humidity: Double, precipitationProbability: Double, summary: String, icon: UIImage, date: Double, sunriseTime: Double, sunsetTime: Double){
		self.temperatureMin = temperatureMin
		self.temperatureMax = temperatureMax
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.icon = icon
		self.date = date
		self.sunriseTime = sunriseTime
		self.sunsetTime = sunsetTime
	}
	
	required init?(JSON: [String : AnyObject]) {
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
		
		let icon = WeatherIcon(rawValue: iconString).image
		self.temperatureMin = temperatureMin
		self.temperatureMax = temperatureMax
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.icon = icon
		self.date = date
		self.sunriseTime = sunriseTime
		self.sunsetTime = sunsetTime
	}
	
	required init(coder aDecoder: NSCoder) {
		self.temperatureMin = aDecoder.decodeDouble(forKey: "temperatureMin")
		self.temperatureMax = aDecoder.decodeDouble(forKey: "temperatureMax")
		self.humidity = aDecoder.decodeDouble(forKey: "humidity")
		self.precipitationProbability = aDecoder.decodeDouble(forKey: "precipitationProbability")
		// FIXME: This is forced unwrapped
		self.summary = aDecoder.decodeObject(forKey: "summary") as! String
		self.icon = aDecoder.decodeObject(forKey: "icon") as! UIImage
		self.date = aDecoder.decodeDouble(forKey: "date")
		self.sunriseTime = aDecoder.decodeDouble(forKey: "sunriseTime")
		self.sunsetTime = aDecoder.decodeDouble(forKey: "sunsetTime")
	}
	
	func encodeWithCoder(_ aCoder: NSCoder!) {
		aCoder.encode(temperatureMin, forKey: "temperatureMin")
		aCoder.encode(temperatureMax, forKey: "temperatureMax")
		aCoder.encode(humidity, forKey: "humidity")
		aCoder.encode(precipitationProbability, forKey: "precipitationProbability")
		aCoder.encode(summary, forKey: "summary")
		aCoder.encode(icon, forKey: "icon")
		aCoder.encode(date, forKey: "date")
		aCoder.encode(sunriseTime, forKey: "sunriseTime")
		aCoder.encode(temperatureMin, forKey: "sunsetTime")
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
