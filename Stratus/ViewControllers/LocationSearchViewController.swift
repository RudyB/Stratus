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

class LocationSearchViewController: UIViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	lazy var geocoder = CLGeocoder()
	
	var pages: [Page]?
	var filtered:[Location?] = []
	var currentLocation: CLLocationCoordinate2D?
	var region: CLCircularRegion?
	
	override func viewWillAppear(_ animated: Bool) {
		loadPages()
		if let curLocCoord = pages?.first?.location?.coordinates {
			currentLocation = CLLocationCoordinate2D(latitude: curLocCoord.latitude, longitude: curLocCoord.longitude)
			region = CLCircularRegion(center: currentLocation!, radius: 90000, identifier: "Hint Region")
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
	
	
	// MARK: Helper Functions
    
    private func loadPages(){
        
        let locationData = UserDefaults.standard.object(forKey: "savedUserPages") as? Data
        
        if let locationData = locationData, let locationArray = try? decoder.decode([Page].self, from: locationData) {
            self.pages = locationArray
        }
    }
    private func savePages() -> Bool {
        guard let pageArray = pages, let pageData = try? encoder.encode(pageArray) else {
            return false
        }
        
        UserDefaults.standard.set(pageData, forKey: "savedUserPages")
        return true
    }
    
}

extension LocationSearchViewController: UISearchBarDelegate {
	// MARK: - SearchBar Delegate Methods
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		geocoder.geocodeAddressString(searchText, in: region) { (placemarks, error) -> Void in
			if(error != nil){
				print("Error", error!.localizedDescription)
			}
			guard let placemarks = placemarks else {
				return
			}
			DispatchQueue.main.async {
				self.filtered = placemarks.map { (placemark) -> Location? in
					guard let city = placemark.locality, let state = placemark.administrativeArea, let coordinate = placemark.location?.coordinate else { return nil }
					return Location(coordinates: Coordinate(coordinate), city: city, state: state)
				}
				
				self.tableView.reloadData()
			}
		}
	}
}


extension LocationSearchViewController: UITableViewDataSource {
	// MARK: TableView Delegate Methods
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filtered.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		if let name = filtered[indexPath.row]?.prettyLocationName {
			cell.textLabel?.text =  name
		}
		return cell;
	}
}

extension LocationSearchViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let item = filtered[indexPath.row] {
			var locationAlreadyExists = false
			
			pages?.forEach{ (page) in
				if page.location?.city == item.city {
					locationAlreadyExists = true
				}
			}
			if locationAlreadyExists {
				showAlert(target: self, title: "Location Already Exists", message: "Select another location")
			} else {
				let newPage = Page(location: item)
				pages?.append(newPage)
				if savePages() {
					self.notificationCenter.post(name: Notification.Name("PagesChanged"), object: nil)
					self.dismiss(animated: true, completion: nil)
				}
			}
		}
	}
	
}


