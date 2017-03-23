//
//  CurrentWeather.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/21/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit

class CurrentWeather: NSObject{
	let temperature: Double
	let apparentTemperature: Double
	let humidity: Double
	let precipitationProbability: Double
	let summary: String
	let windSpeed: Double
	let cloudCover: Double
	let icon: UIImage
	let visibility: Double
	
	init(temperature: Double, apparentTemperature: Double, humidity: Double, precipitationProbability: Double, summary:String, windSpeed: Double, cloudCover: Double, icon: UIImage, visibility: Double){
		self.temperature = temperature
		self.apparentTemperature = apparentTemperature
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.windSpeed = windSpeed
		self.cloudCover = cloudCover
		self.icon = icon
		self.visibility = visibility
	}
	required init?(JSON: [String : AnyObject]) {
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
		
		let icon = WeatherIcon(rawValue: iconString).image
		self.temperature = temperature
		self.humidity = humidity
		self.precipitationProbability = precipitationProbability
		self.summary = summary
		self.icon = icon
		// TODO: Make computed properties
		self.apparentTemperature = apparentTemperature
		self.windSpeed = windSpeed
		self.cloudCover = cloudCover
		self.visibility = visibility
	}
	
	
	required init(coder aDecoder: NSCoder) {
		self.temperature = aDecoder.decodeDouble(forKey: "temperature")
		self.apparentTemperature = aDecoder.decodeDouble(forKey: "apparentTemperature")
		self.humidity =  aDecoder.decodeDouble(forKey: "humidity")
		self.precipitationProbability =  aDecoder.decodeDouble(forKey: "precipitationProbability")
		self.summary =  aDecoder.decodeObject(forKey: "summary") as! String
		self.windSpeed =  aDecoder.decodeDouble(forKey: "windSpeed")
		self.cloudCover =  aDecoder.decodeDouble(forKey: "cloudCover")
		self.icon = aDecoder.decodeObject(forKey: "icon") as! UIImage
		self.visibility =  aDecoder.decodeDouble(forKey: "visibility")
	}
	
	func encodeWithCoder(_ aCoder: NSCoder!) {
		aCoder.encode(temperature, forKey: "temperature")
		aCoder.encode(apparentTemperature, forKey: "apparentTemperature")
		aCoder.encode(humidity, forKey: "humidity")
		aCoder.encode(precipitationProbability, forKey: "precipitationProbability")
		aCoder.encode(summary, forKey: "summary")
		aCoder.encode(windSpeed, forKey: "windSpeed")
		aCoder.encode(cloudCover, forKey: "cloudCover")
		aCoder.encode(icon, forKey: "icon")
		aCoder.encode(visibility, forKey: "visibility")
	}
}



extension CurrentWeather: JSONDecodable, Weather {
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
