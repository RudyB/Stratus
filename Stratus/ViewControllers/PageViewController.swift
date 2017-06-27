//
//  ViewController.swift
//  Stratus
//
//  Created by Rudy Bermudez on 3/20/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
	
	var pages: [Page]? {
		didSet {
			updatePages()
		}
	}
	
	lazy var notificationCenter: NotificationCenter = {
		return NotificationCenter.default
	}()
    
    lazy var encoder: JSONEncoder = {
        return JSONEncoder()
    }()
    
    lazy var decoder: JSONDecoder = {
        return JSONDecoder()
    }()
	
	let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setupPageViewController()
		//setupSettingsButton()
		loadPages()
		
		setupPageControl()
		setupNotificationCenter()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	private func loadPages(){
        
		let locationData = UserDefaults.standard.object(forKey: "savedUserPages") as? Data
		
		if let locationData = locationData, let locationArray = try? decoder.decode([Page].self, from: locationData) {
			self.pages = locationArray
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
        
		let locationData = try! encoder.encode(defaultPages)
		UserDefaults.standard.set(locationData, forKey: "savedUserPages")
	}
	
	private func setupPageViewController() {
		
		pageVC.dataSource = self
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
	
	private func setupSettingsButton() {
		let button = UIButton(frame: CGRect())
		button.setImage(#imageLiteral(resourceName: "Settings"), for: .normal)
		self.view.addSubview(button)
		
		// Set Margins
		let margins = view.layoutMarginsGuide
		button.heightAnchor.constraint(equalToConstant: 25).isActive = true
		button.widthAnchor.constraint(equalToConstant: 25).isActive = true
		button.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
		button.topAnchor.constraint(equalTo: margins.topAnchor, constant: 40).isActive = true
		button.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func setupNotificationCenter() {
		notificationCenter.addObserver(forName: NSNotification.Name("PagesChanged"), object: nil, queue: nil) { (_) -> Void in
			DispatchQueue.main.async {
				self.loadPages()
			}
		}
	}
	
	var updatePersistantData: ((Page, Int) -> Void) {
		return {
			(page, index) in
			guard let pagesData = UserDefaults.standard.object(forKey: "savedUserPages") as? Data, var pageArray = try? self.decoder.decode([Page].self, from: pagesData) else {
				print("Update Persistant Data Failed")
				return
			}
			pageArray[index].currentWeather = page.currentWeather
			pageArray[index].location = page.location
            
            if let locationData = try? self.encoder.encode(pageArray) {
                UserDefaults.standard.set(locationData, forKey: "savedUserPages")
            }
		}
		
	}
	
	func updatePages() {
		DispatchQueue.main.async {
			guard let pages = self.pages else {
				return
			}
			if pages.count > 0 {
				let initalVC = self.getItemController(0)!
				self.pageVC.setViewControllers([initalVC], direction: .forward, animated: true, completion: nil)
			}
		}
	}
	
}

extension PageViewController: UIPageViewControllerDataSource {
	
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
	
	// MARK: - Page Indicator
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return pages?.count ?? 0
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return 0
	}
}

