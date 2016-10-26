//
//  PageViewController.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/26/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit
import CoreLocation

protocol RootTableViewDelegate {
	func getLocations() -> [LocationData]
	func refreshPageController()
}

class PageViewController: UIViewController, UIPageViewControllerDataSource, RootTableViewDelegate {
	
	fileprivate var pageViewController: UIPageViewController?
	
	var locations:[LocationData]!
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		loadPlaces()
		createPageViewController()
		setupPageControl()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	func initDefaultLocations(){
		let locationArray = [LocationData(useLocationServices: true),
		                   LocationData(coordinates: CLLocationCoordinate2D(latitude: 38.5816, longitude: -121.4944), city: "Sacramento", state: "CA"),
		                   LocationData(coordinates: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), city: "Los Angeles", state: "CA")
		]
		self.locations = locationArray
		let locationData = NSKeyedArchiver.archivedData(withRootObject: locationArray)
		UserDefaults.standard.set(locationData, forKey: "savedUserLocations")
	}
	
	func loadPlaces(){
		let locationData = UserDefaults.standard.object(forKey: "savedUserLocations") as? Data
		
		if let locationData = locationData {
			let locationArray = NSKeyedUnarchiver.unarchiveObject(with: locationData) as? [LocationData]
			
			if let locationArray = locationArray {
				self.locations = locationArray
			}
		} else {
			initDefaultLocations()
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	fileprivate func createPageViewController() {
		
		let pageController = self.storyboard!.instantiateViewController(withIdentifier: "rootPageController") as! UIPageViewController
		pageController.dataSource = self
		
		if locations.count > 0 {
			let firstController = getItemController(0)!
			let startingViewControllers = [firstController]
			pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
		}
		
		pageViewController = pageController
		addChildViewController(pageViewController!)
		self.view.addSubview(pageViewController!.view)
		pageViewController!.didMove(toParentViewController: self)
	}
	
	fileprivate func setupPageControl() {
		let appearance = UIPageControl.appearance()
		appearance.pageIndicatorTintColor = UIColor.gray
		appearance.currentPageIndicatorTintColor = UIColor.white
		appearance.backgroundColor = UIColor(red: 74.0/255, green: 144.0/255, blue: 226.0/255, alpha: 1.0)
	}
	
	// MARK: - UIPageViewControllerDataSource
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		let itemController = viewController as! GenericWeatherLocationViewController
		
		if itemController.itemIndex > 0 {
			return getItemController(itemController.itemIndex-1)
		}
		
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		let itemController = viewController as! GenericWeatherLocationViewController
		
		if itemController.itemIndex+1 < locations.count {
			return getItemController(itemController.itemIndex+1)
		}
		
		return nil
	}
	
	fileprivate func getItemController(_ itemIndex: Int) -> GenericWeatherLocationViewController? {
		
		if itemIndex < locations.count {
			let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "genericViewController") as! GenericWeatherLocationViewController
			pageItemController.locationData = locations[itemIndex]
			pageItemController.updateWeather()
			pageItemController.itemIndex = itemIndex
			return pageItemController
		}
		
		return nil
	}
	
	// MARK: - Page Indicator
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return locations.count
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return 0
	}
	
	// MARK: - RootTableViewDelegate
	
	func getLocations() -> [LocationData] {
		return locations
	}
	
	func refreshPageController() {
		//
	}
	
}
