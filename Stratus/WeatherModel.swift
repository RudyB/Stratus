//
//  WeatherModel.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/23/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit
import RealmSwift


class WeatherData: Object {
	var  dailyWeather = List<DailyWeather>()
	var hourlyWeather = List<HourlyWeather>()
	dynamic var currentWeather: CurrentWeather = CurrentWeather()
	
	convenience init(dailyWeather: List<DailyWeather>, hourlyWeather: List<HourlyWeather>, currentWeather: CurrentWeather) {
		self.init()
		self.dailyWeather = dailyWeather
		self.hourlyWeather = hourlyWeather
		self.currentWeather = currentWeather
	}
}
