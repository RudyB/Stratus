//
//  ForecastClient.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/21/16.
//

import Foundation

enum Forecast: Endpoint {
	case current(token: String, coordinate: Coordinate)
	case hourly(token: String, coordinate: Coordinate)
	case daily(token: String, coordinate: Coordinate)
	
	var baseURL: URL {
		return URL(string: "https://api.forecast.io")!
	}
	
	var path: String{
		switch self {
		case .current(let token, let coordinate):
			return "/forecast/\(token)/\(coordinate.latitude),\(coordinate.longitude)"
		case .hourly(let token, let coordinate):
			return "/forecast/\(token)/\(coordinate.latitude),\(coordinate.longitude)"
		case .daily(let token, let coordinate):
			return "/forecast/\(token)/\(coordinate.latitude),\(coordinate.longitude)"
		}
	}
	var request: URLRequest {
		let url = URL(string: path, relativeTo: baseURL)!
		return URLRequest(url: url)
	}
	var jsonParsingArguement: String {
		switch self {
		case .daily(token: _, coordinate: _):
			return "daily"
		case .hourly(token: _, coordinate: _):
			return "hourly"
		case .current(token: _, coordinate: _):
			return "currently"
		}
	}
}

class ForecastAPIClient: APIClient {
	
	let configuration: URLSessionConfiguration
	lazy var session: URLSession = {
		return URLSession(configuration: self.configuration)
	}()
	
	fileprivate let token: String
	
	
	init(config: URLSessionConfiguration, APIKey: String){
		self.configuration = config
		self.token = APIKey
	}
	
	convenience init(APIKey: String) {
		self.init(config: URLSessionConfiguration.default, APIKey: APIKey)
	}

	func fetchCurrentWeather(_ coordinate: Coordinate, completion: @escaping(APIResult<CurrentWeather>) -> Void) {
		let request = Forecast.current(token: self.token, coordinate: coordinate).request
		
		fetch(request: request, parse: { json -> CurrentWeather? in
			// Parse from JSON response to CurrentWeather
			
			if let currentWeatherDictionary = json["currently"] as? [String: AnyObject]{
				return CurrentWeather(JSON: currentWeatherDictionary)
			} else {
				return nil
			}
			}, completion: completion)
	}
	
	func fetchDailyWeather(_ coordinate: Coordinate, completion: @escaping (APIResult<[DailyWeather]>) -> Void) {
		let request = Forecast.current(token: self.token, coordinate: coordinate).request
		
		fetch(request: request, parse: { json -> [DailyWeather]? in
			// Parse from JSON response to CurrentWeather
			var dailyForecasts:[DailyWeather] = []
			if let dailyWeatherDictionary = json["daily"]?["data"] as? [[String:AnyObject]]{
				for data in dailyWeatherDictionary {
					if let forecast = DailyWeather(JSON: data){
						dailyForecasts.append(forecast)
					}
				}
				return dailyForecasts
			} else {
				return nil
			}
			}, completion: completion)
	}
	
	func fetchHourlyWeather(_ coordinate: Coordinate, completion: @escaping (APIResult<[HourlyWeather]>) -> Void) {
		let request = Forecast.current(token: self.token, coordinate: coordinate).request
		
		fetch(request: request, parse: { json -> [HourlyWeather]? in
			// Parse from JSON response to CurrentWeather
			var hourlyForecasts:[HourlyWeather] = []
			if let hourlyWeatherDictionary = json["hourly"]?["data"] as? [[String:AnyObject]]{
				for data in hourlyWeatherDictionary {
					if let forecast = HourlyWeather(JSON: data){
						hourlyForecasts.append(forecast)
					}
				}
				return hourlyForecasts
			} else {
				return nil
			}
			}, completion: completion)
	}
	
	func fetchAllWeatherData(_ coordinate: Coordinate, completion: @escaping (APIResult<WeatherData>) -> Void){
		let request = Forecast.current(token: self.token, coordinate: coordinate).request
		
		fetch(request: request, parse: { json -> WeatherData? in
			var hourlyForecasts:[HourlyWeather] = []
			var dailyForecasts: [DailyWeather] = []
			
			
			if let hourlyWeatherDictionary = json["hourly"]?["data"] as? [[String:AnyObject]],
				let dailyWeatherDictionary = json["daily"]?["data"] as? [[String:AnyObject]],
				let currentWeatherDictionary = json["currently"] as? [String: AnyObject],
				let currentForecast = CurrentWeather(JSON: currentWeatherDictionary){
				
				for data in hourlyWeatherDictionary {
					if let forecast = HourlyWeather(JSON: data){
						hourlyForecasts.append(forecast)
					}
				}
				for data in dailyWeatherDictionary {
					if let forecast = DailyWeather(JSON: data){
						dailyForecasts.append(forecast)
					}
				}
				return WeatherData(dailyWeather: dailyForecasts, hourlyWeather: hourlyForecasts, currentWeather: currentForecast)
				
			} else {
				return nil
			}
			}, completion: completion)
	}

	
}
