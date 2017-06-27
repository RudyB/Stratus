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
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func toggleTableViewEdit(_ sender: Any) {
        if locationsTableView.isEditing{
            locationsTableView.setEditing(false, animated: false)
            editButton.style = .plain
            editButton.title = "Edit"
        }
        else{
            locationsTableView.setEditing(true, animated: true)
            editButton.title = "Done"
            editButton.style =  .done
        }
        
    }
    
    
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
		cell.selectionStyle = .none
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
        print("Item Selected")
        if let selectedPage = pages?[indexPath.row], let locName = selectedPage.location?.city {
            print("Selected: \(locName)")
        }
	}
    
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
	}
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.row == 0 {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard var pages = pages else {
            return
        }
        let itemToMove = pages[sourceIndexPath.row]
        let _ = pages.remove(at: sourceIndexPath.row)
        pages.insert(itemToMove, at: destinationIndexPath.row)
        self.pages = pages
        let _ = try? Page.savePages(pages: pages)
        self.notificationCenter.post(name: Notification.Name("PagesChanged"), object: nil)
        
    }
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == UITableViewCellEditingStyle.delete) {
            guard var pages = self.pages else {
                showAlert(target: self, title: "Error", message: "Pages have not yet been loaded.")
                return
            }
            if indexPath.row != 0 {
                
                // handle delete (by removing the data from your array and updating the tableview)
                tableView.beginUpdates()
                pages.remove(at: indexPath.row)
                self.pages = pages
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                
                
                let _ = try? Page.savePages(pages: pages)
                self.notificationCenter.post(name: Notification.Name("PagesChanged"), object: nil)
                
                
			} else {
                // This else block should be unreacable. The first cell cannot be edited
				showAlert(target: self, title: "Error", message: "You Cannot Delete Your Current Location")
			}
			
		}
	}
}
