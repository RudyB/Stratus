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
	    
	
	var pages:[Page]?
	
	lazy var notificationCenter: NotificationCenter = {
		return NotificationCenter.default
	}()
	
	override func viewWillAppear(_ animated: Bool) {
		addLongGestureRecognizerForTableView()
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
	
	var snapshot: UIView?
	var sourceIndexPath: IndexPath?
	
	func addLongGestureRecognizerForTableView() {
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SettingsPageViewController.longPressGestureRecognized(longPress:)))
		self.locationsTableView.addGestureRecognizer(longPress)
	}
	
	
	@objc
	func longPressGestureRecognized(longPress: UILongPressGestureRecognizer) {
		let state = longPress.state
		let location = longPress.location(in: self.locationsTableView)
		guard let indexPath = self.locationsTableView.indexPathForRow(at: location) else {
			self.cleanup()
			return
		}
		switch state {
		case .began:
			sourceIndexPath = indexPath
			guard let cell = self.locationsTableView.cellForRow(at: indexPath) else { return }
			snapshot = self.customSnapshotFromView(inputView: cell)
			guard  let snapshot = self.snapshot else { return }
			var center = cell.center
			snapshot.center = center
			snapshot.alpha = 0.0
			self.locationsTableView.addSubview(snapshot)
			UIView.animate(withDuration: 0.25, animations: {
				center.y = location.y
				snapshot.center = center
				snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
				snapshot.alpha = 0.98
				cell.alpha = 0.0
			}, completion: { (finished) in
				cell.isHidden = true
			})
			break
		case .changed:
			guard  let snapshot = self.snapshot else {
				return
			}
			var center = snapshot.center
			center.y = location.y
			snapshot.center = center
			guard let sourceIndexPath = self.sourceIndexPath  else {
				return
			}
			if indexPath != sourceIndexPath && indexPath.row != 0 {
				swap(&pages![indexPath.row], &pages![sourceIndexPath.row])
				self.locationsTableView.moveRow(at: sourceIndexPath, to: indexPath)
				self.sourceIndexPath = indexPath
				let _ = try? Page.savePages(pages: pages!)
				self.notificationCenter.post(name: Notification.Name("PagesChanged"), object: nil)
			}
			break
		default:
			guard let cell = self.locationsTableView.cellForRow(at: indexPath) else {
				return
			}
			guard  let snapshot = self.snapshot else {
				return
			}
			cell.isHidden = false
			cell.alpha = 0.0
			UIView.animate(withDuration: 0.25, animations: {
				snapshot.center = cell.center
				snapshot.transform = CGAffineTransform.identity
				snapshot.alpha = 0
				cell.alpha = 1
			}, completion: { (finished) in
				self.cleanup()
			})
		}
	}
	
	private func cleanup() {
		self.sourceIndexPath = nil
		snapshot?.removeFromSuperview()
		self.snapshot = nil
		self.locationsTableView.reloadData()
	}
	
	
	private func customSnapshotFromView(inputView: UIView) -> UIView? {
		UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
		if let CurrentContext = UIGraphicsGetCurrentContext() {
			inputView.layer.render(in: CurrentContext)
		}
		guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
			UIGraphicsEndImageContext()
			return nil
		}
		UIGraphicsEndImageContext()
		let snapshot = UIImageView(image: image)
		snapshot.layer.masksToBounds = false
		snapshot.layer.cornerRadius = 0
		snapshot.layer.shadowOffset = CGSize(width: -5, height: 0)
		snapshot.layer.shadowRadius = 5
		snapshot.layer.shadowOpacity = 0.4
		return snapshot
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
			if let weather = page.weatherData?.currentWeather {
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
        
        dismiss(animated: true) {
            self.notificationCenter.post(name: NSNotification.Name("JumpToPage"), object: nil, userInfo: ["page":indexPath.row])
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
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    // Used to check that the proposed cell destination is valid. You cannot replace the current location which should always be the first cell
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
