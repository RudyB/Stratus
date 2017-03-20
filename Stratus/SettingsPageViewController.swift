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

class SettingsPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {

	@IBOutlet weak var locationsTableView: UITableView!
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	
	@IBAction func backButtonAction(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)	
	}
	var locations:[Location]?
	
	override func viewWillAppear(_ animated: Bool) {
		loadPlaces()
		locationsTableView.reloadData()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	// MARK: UITableViewDelegate
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let locations = locations {
			return locations.count
		} else {
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.locationsTableView.dequeueReusableCell(withIdentifier: "settingsTableViewCell") as! SettingsTableViewCell
		if let location = locations?[(indexPath as NSIndexPath).item] {
			cell.locationLabel.text = location.description
//			let currentWeather = location.currentWeather
//			if let currentWeather = currentWeather {
//				cell.weatherIcon.image = currentWeather.icon
//				cell.currentTemperatureLabel.text = currentWeather.temperatureString
//			}
			return cell
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == UITableViewCellEditingStyle.delete) {
			if (indexPath as NSIndexPath).item != 0 {
				// handle delete (by removing the data from your array and updating the tableview)
				tableView.beginUpdates()
				tableView.deleteRows(at: [indexPath], with: .automatic)
				locations?.remove(at: (indexPath as NSIndexPath).item)

				// FIXME: Force Unwrapped locations
				let locationData = NSKeyedArchiver.archivedData(withRootObject: locations!)
				UserDefaults.standard.set(locationData, forKey: "savedUserLocations")
				tableView.reloadData()
				tableView.endUpdates()
			} else {
				showAlert("Error", message: "You Cannot Delete Your Current Location")
				// TODO: Rudy - Make it so the delete that is shown on slide disappears
			}
			
		}
	}
	
	func showAlert(_ title: String, message: String? = nil, style: UIAlertControllerStyle = .alert, actionList:[UIAlertAction] = [UIAlertAction(title: "OK", style: .default, handler: nil)] ) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: style)
		for action in actionList {
			alert.addAction(action)
		}
		present(alert, animated: true, completion: nil)
	}
	
	func loadPlaces(){
		let locationData = UserDefaults.standard.object(forKey: "savedUserLocations") as? Data
		
		if let locationData = locationData {
			let locationArray = NSKeyedUnarchiver.unarchiveObject(with: locationData) as? [Location]
			
			if let locationArray = locationArray {
				self.locations = locationArray
				locationArray.map({ (locDat) -> Void in
					print(locDat.city)
				})
			}
		}
	}

}
