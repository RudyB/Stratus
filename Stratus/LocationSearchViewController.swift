//
//  LocationSearchViewController.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/27/16.
//  Copyright © 2016 Rudy Bermudez. All rights reserved.
//

import UIKit
import CoreLocation

class ResultCell: UITableViewCell {
	
	@IBOutlet weak var resultTitle: UILabel!
}

class LocationSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	let geocoder = CLGeocoder()
	
	var searchActive : Bool = false
	var locations:[Location]?
	var filtered:[Location?] = []
	var currentLocation: CLLocationCoordinate2D?
	var region: CLCircularRegion?
	
	override func viewWillAppear(_ animated: Bool) {
		loadLocations()
		if let curLocCoord = locations?.first?.coordinates {
			currentLocation = CLLocationCoordinate2D(latitude: curLocCoord.latitude, longitude: curLocCoord.longitude)
			region = CLCircularRegion(center: currentLocation!, radius: 50000, identifier: "Hint Region")
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/* Setup delegates */
		tableView.delegate = self
		tableView.dataSource = self
		searchBar.delegate = self
		searchBar.becomeFirstResponder()
		
	}
	
	// MARK: - SearchBar Delegate Methods
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchActive = true;
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		searchActive = false;
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchActive = false;
		self.dismiss(animated: true, completion: nil)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchActive = false;
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		geocoder.geocodeAddressString(searchText, in: region, completionHandler: {(placemarks, error) -> Void in
			if((error) != nil){
				print("Error", error)
			}
			if let placemarks = placemarks {
				self.filtered = placemarks.map({ (placemark) -> Location? in
					
					guard let city = placemark.locality, let state = placemark.administrativeArea, let coordinate = placemark.location?.coordinate else { return nil}
					return Location(coordinate: coordinate, city: city, state: state)
				})
			}
		})
		
		if(filtered.count == 0){
			searchActive = false;
		} else {
			searchActive = true;
		}
		self.tableView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: TableView Delegate Methods
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(searchActive) {
			return filtered.count
		}
		return 0;
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		if(searchActive){
			if let city = filtered[(indexPath as NSIndexPath).row]?.city, let state = filtered[(indexPath as NSIndexPath).row]?.state {
				cell.textLabel?.text = "\(city), \(state)"
			}
			
		}
		return cell;
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let item = filtered[(indexPath as NSIndexPath).row] {
			var locationAlreadyExists = false
			
			locations?.map({ (locationData) -> Void in
				if locationData.city == item.city {
					locationAlreadyExists = true
				}
			})
			if locationAlreadyExists {
				showAlert("Location Already Exists", message: "Select another location")
			} else {
				locations?.append(item)
				if saveLocations() {
					self.dismiss(animated: true, completion: nil)
				}
			}
		}
	}
	
	// MARK: Helper Functions
	
	func loadLocations() -> Bool {
		guard let locationData = UserDefaults.standard.object(forKey: "savedUserLocations") as? Data, let locationArray = NSKeyedUnarchiver.unarchiveObject(with: locationData) as? [Location] else {
			return false
		}
		self.locations = locationArray
		return true
	}
	
	func saveLocations() -> Bool {
		guard let locationArray = locations else {
			return false
		}
		let locationData = NSKeyedArchiver.archivedData(withRootObject: locationArray)
		UserDefaults.standard.set(locationData, forKey: "savedUserLocations")
		return true
	}
	func showAlert(_ title: String, message: String? = nil, style: UIAlertControllerStyle = .alert, actionList:[UIAlertAction] = [UIAlertAction(title: "OK", style: .default, handler: nil)] ) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: style)
		for action in actionList {
			alert.addAction(action)
		}
		present(alert, animated: true, completion: nil)
	}
	
}


