//
//  WeatherModel.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/23/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit

protocol Weather: JSONDecodable {
	var temperature: Double { get }
	var humidity: Double { get }
	var precipitationProbability: Double { get }
	var summary: String { get }
	var icon: UIImage { get }
	
	init?(JSON: [String : AnyObject])
}

struct WeatherData{
	let dailyWeather: [DailyWeather]
	let hourlyWeather: [HourlyWeather]
	let currentWeather: CurrentWeather
}


protocol TestWeather {
	func getWeatherData() -> WeatherData?
}
