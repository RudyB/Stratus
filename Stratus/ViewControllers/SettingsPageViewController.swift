//
//  SettingsPageViewController.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/27/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
	
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var weatherIcon: UIImageView!
	@IBOutlet weak var currentTemperatureLabel: UILabel!
}

class SettingsPageViewController: UIViewController, UINavigationBarDelegate {
	
	@IBOutlet weak var locationsTableView: UITableView!
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	
	@IBAction func backButtonAction(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
    
	
	var pages:[Page]?
	
	lazy var notificationCenter: NotificationCenter = {
		return NotificationCenter.default
	}()
	
	override func viewWillAppear(_ animated: Bool) {
		loadPages()
		locationsTableView.reloadData()
		self.navigationBar.delegate = self
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
    
    private func loadPages(){
        
        do {
            self.pages = try Page.loadPages()
        } catch let e {
            showAlert(target: self, title: "Yikes", message: e.localizedDescription)
        }
    }
	
}

extension SettingsPageViewController: UITableViewDataSource {
	
	// MARK: UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let pages = pages else {
			return 0
		}
		return pages.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.locationsTableView.dequeueReusableCell(withIdentifier: "settingsTableViewCell") as! SettingsTableViewCell
		
		if let page = pages?[indexPath.row], let location =  page.location {
			cell.locationLabel.text = location.prettyLocationName
			if let weather = page.currentWeather {
				cell.weatherIcon.image = weather.icon.image
				cell.currentTemperatureLabel.text = weather.temperatureString
			}
			return cell
		} else {
			cell.locationLabel.text = "Current Location"
			if let weather = pages?[indexPath.row].weatherData?.currentWeather {
				cell.weatherIcon.image = weather.icon.image
				cell.currentTemperatureLabel.text = weather.temperatureString
			}
			return cell
		}
		
	}
}

extension SettingsPageViewController : UITableViewDelegate {
	
	// MARK: UITableViewDelegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == UITableViewCellEditingStyle.delete) {
			if indexPath.row != 0 {
				// handle delete (by removing the data from your array and updating the tableview)
				tableView.beginUpdates()
				tableView.deleteRows(at: [indexPath], with: .automatic)
				pages?.remove(at: indexPath.row)
				
				// FIXME: Force Unwrapped locations
				let locationData = NSKeyedArchiver.archivedData(withRootObject: pages!)
				UserDefaults.standard.set(locationData, forKey: "savedUserPages")
				self.notificationCenter.post(name: Notification.Name("PagesChanged"), object: nil)
				tableView.reloadData()
				tableView.endUpdates()
			} else {
				showAlert(target: self, title: "Error", message: "You Cannot Delete Your Current Location")
				
				// TODO: Rudy - Make it so the delete that is shown on slide disappears
			}
			
		}
	}
}
