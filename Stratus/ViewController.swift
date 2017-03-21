//
//  ViewController.swift
//  Stratus
//
//  Created by Rudy Bermudez on 3/20/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import UIKit

class Page: NSObject {
	var location: Location?
	var weatherData: WeatherData?
	var currentWeather: CurrentWeather?
	var usesLocationServices: Bool? = false
	
	init(location: Location?, weatherData: WeatherData? = nil, usesLocationServices: Bool = false) {
		self.location = location
		self.weatherData = weatherData
		self.usesLocationServices = usesLocationServices
	}
	
	required init(coder aDecoder: NSCoder) {
		self.location = aDecoder.decodeObject(forKey: "location") as? Location
		self.weatherData = aDecoder.decodeObject(forKey: "weatherData") as? WeatherData
		self.currentWeather = aDecoder.decodeObject(forKey: "currentWeather") as? CurrentWeather
		self.usesLocationServices = aDecoder.decodeObject(forKey: "usesLocationServices") as? Bool
	}
	
	func encodeWithCoder(_ aCoder: NSCoder!) {
		aCoder.encode(location, forKey: "location")
		aCoder.encode(weatherData, forKey: "weatherData")
		aCoder.encode(currentWeather, forKey: "currentWeather")
		aCoder.encode(usesLocationServices, forKey: "usesLocationServices")
	}
	
	convenience init(usesLocationServices: Bool = true) {
		self.init(location: nil, weatherData: nil, usesLocationServices: usesLocationServices)
	}
}

class ViewController: UIViewController {
	
	var pages: [Page]?
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		loadPages()
		setupPageViewController()
		setupPageControl()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	private func loadPages(){
		let locationData = UserDefaults.standard.object(forKey: "savedUserPages") as? Data
		
		if let locationData = locationData {
			let locationArray = NSKeyedUnarchiver.unarchiveObject(with: locationData) as? [Page]
			
			if let locationArray = locationArray {
				self.pages = locationArray
			}
		} else {
			initDefaultPages()
		}
	}
	
	
	private func initDefaultPages() {
			let defaultPages = [
				Page(usesLocationServices: true),
				Page(location: Location(coordinates: Coordinate(latitude: 38.5816, longitude: -121.4944), city: "Sacramento", state: "CA")),
				Page(location: Location(coordinates: Coordinate(latitude: 34.0522, longitude: -118.2437), city: "Los Angeles", state: "CA"))
				
			]
		pages = defaultPages
		let locationData = NSKeyedArchiver.archivedData(withRootObject: defaultPages)
		UserDefaults.standard.set(locationData, forKey: "savedUserPages")
	}
	
	private func setupPageViewController() {
		
		let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		
		pageVC.delegate = self
		pageVC.dataSource = self
		
		guard let pages = pages else {
			return
		}
		if pages.count > 0 {
			let initalVC = getItemController(0)!
			pageVC.setViewControllers([initalVC], direction: .forward, animated: true, completion: nil)
		}
		
		addChildViewController(pageVC)
		self.view.addSubview(pageVC.view)
		pageVC.didMove(toParentViewController: self)
	}
	
	
	
	private func setupPageControl() {
		let appearance = UIPageControl.appearance()
		appearance.pageIndicatorTintColor = UIColor.gray
		appearance.currentPageIndicatorTintColor = UIColor.white
		appearance.backgroundColor = UIColor(red: 74.0/255, green: 144.0/255, blue: 226.0/255, alpha: 1.0)
	}
	
	var updatePersistantData: ((Page, Int) -> Void) {
		return {
			(page, index) in
			guard let pagesData = UserDefaults.standard.object(forKey: "savedUserPages") as? Data, var pageArray = NSKeyedUnarchiver.unarchiveObject(with: pagesData) as? [Page] else {
				print("Update Persistant Data Failed")
				return
			}
			pageArray[index].currentWeather = page.currentWeather
			pageArray[index].location = page.location
			let locationData = NSKeyedArchiver.archivedData(withRootObject: pageArray)
			UserDefaults.standard.set(locationData, forKey: "savedUserPages")
		}
		
	}
	
}

extension ViewController: UIPageViewControllerDataSource {
	
	fileprivate func getItemController(_ itemIndex: Int) -> GenericWeatherLocationViewController? {
		guard var pages = pages else {
			return nil
		}
		
		if itemIndex < pages.count {
			let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "genericViewController") as! GenericWeatherLocationViewController
			pageItemController.page = pages[itemIndex]
			pageItemController.updateWeather()
			pageItemController.itemIndex = itemIndex
			pageItemController.updatePersistantData = updatePersistantData
			return pageItemController
		}
		
		return nil
	}
	
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let itemController = viewController as! GenericWeatherLocationViewController
		
		if itemController.itemIndex > 0 {
			return getItemController(itemController.itemIndex-1)
		}
		
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let pages = pages else {
			return nil
		}
		let itemController = viewController as! GenericWeatherLocationViewController
		
		if itemController.itemIndex+1 < pages.count {
			return getItemController(itemController.itemIndex+1)
		}
		
		return nil
	}
}

extension ViewController: UIPageViewControllerDelegate {
	
	// MARK: - Page Indicator
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return pages?.count ?? 0
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return 0
	}
	
}
