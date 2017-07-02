//
//  Page.swift
//  Stratus
//
//  Created by Rudy Bermudez on 3/21/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import Foundation

class Page: Codable {
	var location: Location?
	var weatherData: WeatherData?
	var usesLocationServices: Bool? = false
	
	init(location: Location?, weatherData: WeatherData? = nil, usesLocationServices: Bool = false) {
		self.location = location
		self.weatherData = weatherData
		self.usesLocationServices = usesLocationServices
	}
	
	convenience init(usesLocationServices: Bool = true) {
		self.init(location: nil, weatherData: nil, usesLocationServices: usesLocationServices)
	}
    
    static func loadPages() throws -> [Page] {
        
        guard let pageData = UserDefaults.standard.object(forKey: "savedUserPages") as? Data else {
            throw NSError(domain: "co.rudybermudez.stratus.page", code: 10, userInfo: nil)
        }
        return try JSONDecoder().decode([Page].self, from: pageData)
    }
    
    static func savePages(pages: [Page]) throws -> Bool {
        
        let pageData = try JSONEncoder().encode(pages)
        UserDefaults.standard.set(pageData, forKey: "savedUserPages")
        return true
    }
    
}
