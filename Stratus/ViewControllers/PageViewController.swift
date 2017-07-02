//
//  ViewController.swift
//  Stratus
//
//  Created by Rudy Bermudez on 3/20/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
	
	
	// The custom UIPageControl
	@IBOutlet weak var locationPageControl: LocationPageControl!
	
	// The UIPageViewController
	var pageController: UIPageViewController!
	
	// The pages it contains
    var pages = [GenericWeatherLocationViewController]()
	
	// Track the current index
	var currentIndex: Int?
	private var pendingIndex: Int?
	
    
	var pageData: [Page]? {
		didSet {
			self.updateViewControllers()
		}
	}
	
    
	lazy var notificationCenter: NotificationCenter = {
		return NotificationCenter.default
	}()
    
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Application State
		
		
		// 1. Load Data
		loadData()
		
		// 2. Create PageViewController
		setupPageViewController()
		
		// 3. Configure Custom PageControl
		setupPageControl()
		
		// 4. Setup Notification Center
		setupNotificationCenter()
		
		
    }
	
	
	private func loadData(){
        
        if let pageData = try? Page.loadPages() {
            self.pageData = pageData
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
		self.pageData = defaultPages
        
        do {
            let _ = try Page.savePages(pages: defaultPages)
        } catch let e {
            showAlert(target: self, title: "Yikes", message: e.localizedDescription)
        }
	}
	
	func updateViewControllers() {
		DispatchQueue.main.async {
			guard let pageData = self.pageData else {
				return
			}
			self.pages = []
			for index in 0 ..< pageData.count {
				if let vc = self.getItemController(index) {
					self.pages.append(vc)
				}
			}
			if !self.pages.isEmpty {
				self.locationPageControl.numberOfPages = self.pages.count
				self.pageController.setViewControllers([self.pages.first!], direction: .forward, animated: false, completion: nil)
			}
		}
	}
	
	func setupPageViewController() {
		// Create the page container
		pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		pageController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 35)
		pageController.delegate = self
		pageController.dataSource = self
		addChildViewController(pageController)
		self.view.addSubview(pageController.view)
	}
	
	private func setupPageControl() {
        
        view.bringSubview(toFront: locationPageControl)
        locationPageControl.numberOfPages = pages.count
        locationPageControl.currentPage = 0
	}
	
	
	private func setupNotificationCenter() {
		notificationCenter.addObserver(forName: NSNotification.Name("PagesChanged"), object: nil, queue: nil) { (_) -> Void in
			DispatchQueue.main.async {
				self.loadData()
			}
		}
        notificationCenter.addObserver(forName: NSNotification.Name("JumpToPage"), object: nil, queue: nil) { (notification) in
            if let pageNumber = notification.userInfo?["page"] as? Int {
                DispatchQueue.main.async {
                    self.jumptoPage(index: pageNumber)
                }
            }
            
        }
	}
	
	var updatePersistantData: ((Page, Int) -> Void) {
		return {
			(page, index) in
            do {
				
				var localPageData = self.pageData
				localPageData?[index] = page
				let _ = try Page.savePages(pages: localPageData!)
				return
				
            } catch let error {
                showAlert(target: self, title: "Yikes", message: error.localizedDescription)
                return
            }
		}
		
	}
	
	
	
    
    func jumptoPage(index : Int) {
        print("Attemping to jump to page \(index)")
		
		guard var currentIndex = currentIndex else {
			return
		}
		
		let selectedPage = pages[index]
        
        if index < currentIndex {
            pageController.setViewControllers([selectedPage], direction: .reverse, animated: true, completion: nil)
        } else if index == currentIndex {
            pageController.setViewControllers([selectedPage], direction: .reverse, animated: false, completion: nil)
            
        } else {
            pageController.setViewControllers([selectedPage], direction: .forward, animated: true, completion: nil)
        }
		
		if let pageIndex = pages.index(of: selectedPage) {
			currentIndex = pageIndex
		}
		locationPageControl.currentPage = currentIndex
    }
	
}

extension PageViewController: UIPageViewControllerDataSource {
	
	fileprivate func getItemController(_ itemIndex: Int) -> GenericWeatherLocationViewController? {
		guard var pageData = pageData else {
			return nil
		}
		
		if itemIndex <= pages.count {
			let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "genericViewController") as! GenericWeatherLocationViewController
			pageItemController.page = pageData[itemIndex]
			pageItemController.updateWeather()
			pageItemController.itemIndex = itemIndex
			pageItemController.updatePersistantData = updatePersistantData
			return pageItemController
		}
		
		return nil
	}
    
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let currentIndex = pages.index(of: viewController as! GenericWeatherLocationViewController)!
		if currentIndex == 0 {
			return nil
		}
		let previousIndex = abs((currentIndex - 1 + pages.count) % pages.count)
		return pages[previousIndex]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let genericWeatherViewController = viewController as? GenericWeatherLocationViewController, let currentIndex = pages.index(of: genericWeatherViewController) else {
			return nil
		}
		if currentIndex == pages.count-1 {
			return nil
		}
		let nextIndex = abs((currentIndex + 1) % pages.count)
		return pages[nextIndex]
	}
}

extension PageViewController: UIPageViewControllerDelegate {
	
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		pendingIndex = pages.index(of: pendingViewControllers.first! as! GenericWeatherLocationViewController)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			currentIndex = pendingIndex
			if let index = currentIndex {
				locationPageControl.currentPage = index
			}
		}
	}
}

