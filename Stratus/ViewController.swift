//
//  ViewController.swift
//  Stratus
//
//  Created by Rudy Bermudez on 3/20/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

class Page: Object {
	dynamic var location: Location?
	dynamic var weatherData: WeatherData?
	
	convenience init(location: Location, weatherData: WeatherData? = nil) {
		self.init()
		self.location = location
		self.weatherData = weatherData
	}
}

class ViewController: UIViewController {
	
	var pages: [Page]?
	
	@IBOutlet weak var containerView: UIView!
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		pages = [
			Page(location: Location(coordinate: CLLocationCoordinate2D(latitude: 38.5816, longitude: -121.4944), city: "Sacramento", state: "CA")),
			Page(location: Location(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), city: "Los Angeles", state: "CA"))
		
		]
		setupPageViewController()
		setupPageControl()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	private func setupPageViewController() {
		let pageVC = PageViewController()
		
		pageVC.delegate = self
		pageVC.dataSource = self
		
		guard let pages = pages else {
			return
		}
		if pages.count > 0 {
			let initalVC = getItemController(0)!
			pageVC.setViewControllers([initalVC], direction: .forward, animated: true, completion: nil)
		}
		containerView.addSubview(pageVC.view)
	}
	
	
	private func setupPageControl() {
		let appearance = UIPageControl.appearance()
		appearance.pageIndicatorTintColor = UIColor.gray
		appearance.currentPageIndicatorTintColor = UIColor.white
		appearance.backgroundColor = UIColor(red: 74.0/255, green: 144.0/255, blue: 226.0/255, alpha: 1.0)
	}

}

extension ViewController: UIPageViewControllerDataSource {
	
	fileprivate func getItemController(_ itemIndex: Int) -> GenericWeatherLocationViewController? {
		guard let pages = pages else {
			return nil
		}
		
		if itemIndex < pages.count {
			let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "genericViewController") as! GenericWeatherLocationViewController
			pageItemController.location = pages[itemIndex].location
			pageItemController.weatherData = pages[itemIndex].weatherData
			pageItemController.updateWeather()
			pageItemController.itemIndex = itemIndex
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
	
}
