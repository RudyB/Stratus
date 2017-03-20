//
//  GenericWeatherLocationViewController.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/26/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit
import CoreLocation


class HourlyWeatherCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	
}

class DailyWeatherTableViewCell: UITableViewCell {
	
	@IBOutlet weak var dayOfTheWeekLabel: UILabel!
	@IBOutlet weak var dailyWeatherIcon: UIImageView!
	@IBOutlet weak var dailyTableViewLowTempLabel: UILabel!
	@IBOutlet weak var dailyTableViewHighTempLabel: UILabel!
}

class GenericWeatherLocationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, PZPullToRefreshDelegate, CLLocationManagerDelegate {
	
	// MARK: - IBOutlets
	
	// VC Outlets
	@IBOutlet weak var scrollView: UIScrollView!
	
	// Top View
	@IBOutlet weak var currentTemperatureLabel: UILabel!
	@IBOutlet weak var currentWeatherIcon: UIImageView!
	@IBOutlet weak var currentSummaryLabel: UILabel!
	@IBOutlet weak var currentLocationLabel: UILabel!
	
	// Hourly Middle View
	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var todayLabel: UILabel!
	@IBOutlet weak var hourlyWeatherCollectionView: UICollectionView!
	@IBOutlet weak var dailyHighTempLabel: UILabel!
	@IBOutlet weak var dailyLowTempLabel: UILabel!
	
	// Daily Weather Table View
	@IBOutlet weak var dailyWeatherTableView: UITableView!
	
	// Lower Detail View
	
	@IBOutlet weak var apparentTemperatureTitleLabel: UILabel!
	@IBOutlet weak var apparentTemperatureValueLabel: UILabel!
	@IBOutlet weak var rainTitleLabel: UILabel!
	@IBOutlet weak var rainValueLabel: UILabel!
	@IBOutlet weak var windTitleLabel: UILabel!
	@IBOutlet weak var windValueLabel: UILabel!
	@IBOutlet weak var humidityTitleLabel: UILabel!
	@IBOutlet weak var humidityValueLabel: UILabel!
	@IBOutlet weak var sunriseTitleLabel: UILabel!
	@IBOutlet weak var sunriseValueLabel: UILabel!
	@IBOutlet weak var sunsetTitleLabel: UILabel!
	@IBOutlet weak var sunsetValueLabel: UILabel!
	@IBOutlet weak var cloudCoverTitleLabel: UILabel!
	@IBOutlet weak var cloudCoverValueLabel: UILabel!
	@IBOutlet weak var visibilityTitleLabel: UILabel!
	@IBOutlet weak var visibilityValueLabel: UILabel!
	
	
	// MARK: - Class Variables
	lazy var forecastAPIClient = ForecastAPIClient(APIKey: "cf79775fc8706066d8edada44ca32ccc")
	
	var location: Location!
	var weatherData: WeatherData?
	var refreshHeaderView: PZPullToRefreshView?
	let activityIndicatorHelper = ActivityIndicatorHelper()
	var itemIndex: Int = 0
	
	var usesLocationServices:Bool = false
	
	lazy var locationManager = LocationManager()
	
	
	// MARK: - Default ViewController Methods
	override func viewWillAppear(_ animated: Bool) {
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if usesLocationServices {
			locationManager.getPermission()
			locationManager.onLocationFix = { [weak self] result in
				switch result {
				case .failure(let error):
					break
				case .success(let currentLocation):
					self?.location = currentLocation
				}
			}
		}
		initializeView()
		
		if usesLocationServices {
			NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
				[unowned self] notification in
				NSLog("Application has Entered Foreground")
				let connected = self.allConnectionsEnabled()
				if connected {
					self.activityIndicatorHelper.showActivityIndicator(self.view)
					NSLog("Weather Call from Foreground Observer")
					self.updateWeather()
				}
			}
		}
		// Do any additional setup after loading the view, typically from a nib.
		
		self.dailyWeatherTableView.delegate = self

		if refreshHeaderView == nil {
			let view = PZPullToRefreshView(frame: CGRect(x: 0, y: 0 - scrollView.bounds.size.height, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height))
			view.delegate = self
			scrollView.addSubview(view)
			refreshHeaderView = view
		}
		
		NSLog("View Did Load")
	}
	
	// MARK: - Display Methods
	func initializeView() {
		if usesLocationServices {
			currentLocationLabel.text = "Loading Location"
		} else {
			currentLocationLabel.text = "\(location.city), \(location.state)"
		}
		currentTemperatureLabel.text = "--"
		currentSummaryLabel.text = ""
		rainTitleLabel.isHidden = true
		rainValueLabel.isHidden = true
		currentWeatherIcon.image = UIImage(named: "default")!
		dailyHighTempLabel.isHidden = true
		dailyLowTempLabel.isHidden = true
		apparentTemperatureTitleLabel.isHidden = true
		apparentTemperatureValueLabel.isHidden = true
		windTitleLabel.isHidden = true
		windValueLabel.isHidden = true
		humidityTitleLabel.isHidden = true
		humidityValueLabel.isHidden = true
		sunriseTitleLabel.isHidden = true
		sunriseValueLabel.isHidden = true
		sunsetTitleLabel.isHidden = true
		sunsetValueLabel.isHidden = true
		cloudCoverTitleLabel.isHidden = true
		cloudCoverValueLabel.isHidden = true
		visibilityTitleLabel.isHidden = true
		visibilityValueLabel.isHidden = true
		NSLog("Screen Initialized")
	}
	
	func display(_ weather: WeatherData) {
		updatePersistentData()
		if usesLocationServices {
			UIApplication.shared.applicationIconBadgeNumber = Int(weather.currentWeather.temperature)
		}
		let date = Date()
		let dayTimePeriodFormatter = DateFormatter()
		dayTimePeriodFormatter.dateFormat = "EEEE"
		self.dayLabel.text = dayTimePeriodFormatter.string(from: date)
		currentTemperatureLabel.text = weather.currentWeather.temperatureString
		apparentTemperatureValueLabel.text = weather.currentWeather.apparentTemperatureString
		rainValueLabel.text = weather.currentWeather.precipitationProbabilityString
		windValueLabel.text = weather.currentWeather.windSpeedString
		sunriseValueLabel.text = weather.dailyWeather[0].sunriseTimeString
		sunsetValueLabel.text = weather.dailyWeather[0].sunsetTimeString
		cloudCoverValueLabel.text = weather.currentWeather.cloudCoverString
		visibilityValueLabel.text = weather.currentWeather.visibilityString
		humidityValueLabel.text = weather.currentWeather.humidityString
		currentSummaryLabel.text = weather.currentWeather.summary
		currentWeatherIcon.image = weather.currentWeather.icon
		currentLocationLabel.text = location.description
		dailyHighTempLabel.text = String(Int(weather.dailyWeather[0].temperatureMax))
		dailyLowTempLabel.text = String(Int(weather.dailyWeather[0].temperatureMin))
		
		rainTitleLabel.isHidden = false
		rainValueLabel.isHidden = false
		apparentTemperatureTitleLabel.isHidden = false
		apparentTemperatureValueLabel.isHidden = false
		windTitleLabel.isHidden = false
		windValueLabel.isHidden = false
		humidityTitleLabel.isHidden = false
		humidityValueLabel.isHidden = false
		sunriseTitleLabel.isHidden = false
		sunriseValueLabel.isHidden = false
		sunsetTitleLabel.isHidden = false
		sunsetValueLabel.isHidden = false
		cloudCoverTitleLabel.isHidden = false
		cloudCoverValueLabel.isHidden = false
		visibilityTitleLabel.isHidden = false
		visibilityValueLabel.isHidden = false
		dayLabel.isHidden = false
		todayLabel.isHidden = false
		dailyHighTempLabel.isHidden = false
		dailyLowTempLabel.isHidden = false
		
		NSLog("Display Updated with latest data")
	}
	
	// MARK: - Update Weather Method
	func updateWeather() {
		activityIndicatorHelper.showActivityIndicator(self.view)
		if usesLocationServices {
			if allConnectionsEnabled(){
				locationManager.updateLocation()
				locationManager.onLocationFix = { [weak self] result in
					switch result {
					case .failure(let error):
						break
					case .success(let currentLocation):
						self?.location = currentLocation
						self?.fetchCurrentWeather()
					}
				}
			}
		} else {
			if activeInternetConnection() {

				fetchCurrentWeather()
			}
		}
	}
	
	// MARK: - Fetch Weather Data Method
	func fetchCurrentWeather(){
		NSLog("Attemping to Update Weather Data")
		if let locationData = location, let coordinates = locationData.coordinates {
			forecastAPIClient.fetchAllWeatherData(coordinates){ result in
				DispatchQueue.main.async{
					self.endPullToRefresh()
					self.stopRefreshIndicator()
				}
				switch result {
				case .success(let weatherData):
					DispatchQueue.main.async{
						self.weatherData = weatherData
						self.display(weatherData)
						self.hourlyWeatherCollectionView.reloadData()
						self.dailyWeatherTableView.reloadData()
						NSLog("Weather Sucsessfully Fetched")
					}
				case .failure(let error as NSError):
					DispatchQueue.main.async{
						self.showAlert("Unable to reterive forecast", message: error.localizedDescription)
						NSLog("Weather Update Failed")
					}
				default: break
				}
			}
		}
		
	}
	// MARK: - Connectivity Checking Methods
	
	func activeInternetConnection() -> Bool {
		if !Reachability.isConnectedToNetwork() {
			self.endPullToRefresh()
			self.stopRefreshIndicator()
			initializeView()
			self.currentLocationLabel.text = "No Internet Connection"
			showAlert("There is no active connection to the Internet", message: "Please check your connection and try again")
			return false
		} else{
			return true
		}
	}
	
	func locationServicesEnabled() -> Bool {
		if CLLocationManager.locationServicesEnabled() {
			switch(CLLocationManager.authorizationStatus()) {
			case .notDetermined:
				self.endPullToRefresh()
				self.stopRefreshIndicator()
				return false
			case .restricted, .denied:
				self.endPullToRefresh()
				self.stopRefreshIndicator()
				initializeView()
				self.currentLocationLabel.text = "Location Disabled"
				DispatchQueue.main.async {
					self.showAlert("Location Services are Disabled", message: "Please Enable Location Services in Settings")
				}
				return false
				
			case .authorizedAlways, .authorizedWhenInUse:
				return true
			}
		} else {
			self.showAlert("Location Services are Disabled", message: "Please Enable Location Services")
			return false
		}
	}
	
	
	func allConnectionsEnabled() -> Bool{
		let internetEnabled = activeInternetConnection()
		let locationEnabled = locationServicesEnabled()
		NSLog("Checking Connectivity\nInternet: \(internetEnabled),  Location: \(locationEnabled)")
		return internetEnabled && locationEnabled
	}
	
	// MARK: - Delegates
	// MARK:
	
	// MARK: PZPullToRefreshDelegate
	
	func pullToRefreshDidTrigger(_ view: PZPullToRefreshView) {
		refreshHeaderView?.isLoading = true
		NSLog("Weather Call from Refresh Control")
		updateWeather()
	}
	
	func pullToRefreshLastUpdated(_ view: PZPullToRefreshView) -> Date {
		return Date()
	}
	
	func endPullToRefresh() {
		self.refreshHeaderView?.isLoading = false
		self.refreshHeaderView?.refreshScrollViewDataSourceDidFinishedLoading(self.scrollView)
	}
	
	// MARK: UIScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		refreshHeaderView?.refreshScrollViewDidScroll(scrollView)
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		refreshHeaderView?.refreshScrollViewDidEndDragging(scrollView)
	}
	
	// MARK: UICollectionViewDelegate
	
	let reuseIdentifier = "hourlyWeatherCollectionViewCell" // also enter this string as the cell identifier in the storyboard
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let hourlyWeather = weatherData?.hourlyWeather {
			if hourlyWeather.count > 24 {
				return 24
			}
		} else {
			self.dayLabel.isHidden = true
			self.todayLabel.isHidden = true
		}
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HourlyWeatherCollectionViewCell
		if let hourlyWeatherData = weatherData?.hourlyWeather {
			cell.timeLabel.text = hourlyWeatherData[(indexPath as NSIndexPath).item].timeString
			cell.imageView.image = hourlyWeatherData[(indexPath as NSIndexPath).item].icon
			cell.temperatureLabel.text = hourlyWeatherData[(indexPath as NSIndexPath).item].temperatureString
		}
		return cell
	}
	
	// MARK: UITableViewDelegate
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let dailyWeatherData = weatherData?.dailyWeather {
			return dailyWeatherData.count - 1
		} else {
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.dailyWeatherTableView.dequeueReusableCell(withIdentifier: "dailyWeatherTableViewCell") as! DailyWeatherTableViewCell
		if let dailyWeatherData = weatherData?.dailyWeather {
			let index = (indexPath as NSIndexPath).item + 1
			cell.dayOfTheWeekLabel.text = dailyWeatherData[index].dateString
			cell.dailyWeatherIcon.image = dailyWeatherData[index].icon
			cell.dailyTableViewHighTempLabel.text = dailyWeatherData[index].temperatureMaxString
			cell.dailyTableViewLowTempLabel.text = dailyWeatherData[index].temperatureMinString
			return cell
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	}
	
	
	// MARK: - Helper Methods
	
	func showAlert(_ title: String, message: String? = nil, style: UIAlertControllerStyle = .alert, actionList:[UIAlertAction] = [UIAlertAction(title: "OK", style: .default, handler: nil)] ) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: style)
		for action in actionList {
			alert.addAction(action)
		}
		present(alert, animated: true, completion: nil)
	}
	func stopRefreshIndicator() {
		activityIndicatorHelper.hideActivityIndicator(self.view)
	}
	
	func updatePersistentData(){
		let locationData = UserDefaults.standard.object(forKey: "savedUserLocations") as? Data
		
		if let locationData = locationData {
			let locationArray = NSKeyedUnarchiver.unarchiveObject(with: locationData) as? [Location]
			if let locationArray = locationArray {
				locationArray[itemIndex].city = self.location.city
				locationArray[itemIndex].state = self.location.state
				let locationData = NSKeyedArchiver.archivedData(withRootObject: locationArray)
				UserDefaults.standard.set(locationData, forKey: "savedUserLocations")
			}
		}
	}
	
	func getWeatherData() -> WeatherData? {
		return weatherData
	}
	
}
