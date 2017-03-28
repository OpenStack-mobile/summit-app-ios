//
//  MenuInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class MenuInterfaceController: WKInterfaceController {
    
    static let identifier = "Menu"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    @IBOutlet weak var loadingImageView: WKInterfaceImage!
    
    // MARK: - Properties
    
    let menuItems: [MenuItem] = {
       
        let events = MenuItem(name: "Events", image: "events", controller: EventFiltersInterfaceController.identifier)
        
        let venues = MenuItem(name: "Venues", image: "venues", controller: VenuesMapInterfaceController.identifier)
        
        let people = MenuItem(name: "People", image: "people", controller: SpeakersInterfaceController.identifier)
        
        let about = MenuItem(name: "About", image: "about", controller: AboutInterfaceController.identifier)
        
        return [events, venues, people, about]
    }()
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // load static menu table view
        
        tableView.setNumberOfRows(menuItems.count, withRowType: MenuCellController.identifier)
        
        for (index, menuItem) in menuItems.enumerate() {
            
            let cell = tableView.rowControllerAtIndex(index) as! MenuCellController
            
            cell.menuLabel.setText(menuItem.name)
            cell.imageView.setImageNamed(menuItem.image)
        }
        
        // configure activity indicator
        loadingImageView.setImageNamed("Activity")
        loadingImageView.startAnimatingWithImagesInRange(NSRange(location: 0, length: 30), duration: 1.0, repeatCount: 0)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // reload UI
        updateUI()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Table View Selection
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        
        let menuItem = menuItems[rowIndex]
        
        self.pushControllerWithName(menuItem.controller, context: nil)
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        tableView.setHidden(Store.shared.cache == nil)
        loadingImageView.setHidden(Store.shared.cache != nil)
        
        if Store.shared.cache == nil {
            
            loadingImageView.startAnimating()
            
            // start loading data
            loadData()
            
        } else {
            
            loadingImageView.stopAnimating()
        }
    }
    
    private func loadData() {
        
        print("Loading Summit data")
        
        Store.shared.summit { [weak self] (response) in
            
            guard let controller = self else { return }
            
            switch response {
                
            case let .Error(error):
                
                print("Error loading summit: ", error)
                
                controller.presentAlertControllerWithTitle("Could not load summit data",
                    message: (error as NSError).localizedFailureReason ?? (error as NSError).localizedDescription,
                    preferredStyle:
                    .Alert,
                    actions: [WKAlertAction(title: "Try again", style:
                        .Cancel, handler: {
                            
                            // attempt to reload data
                            controller.loadData()
                })])
                
            case let .Value(summit):
                
                print("Fetched \(summit.name) summit")
                
                controller.updateUI()
                
                // reload complication controller
                ComplicationController.reloadComplications()
            }
        }
    }
}

// MARK: - Supporting Types

final class MenuCellController: NSObject {
    
    static let identifier = "MenuCell"
    
    @IBOutlet weak var menuLabel: WKInterfaceLabel!
    
    @IBOutlet weak var imageView: WKInterfaceImage!
}

struct MenuItem {
    
    let name: String
    
    let image: String
    
    let controller: String
}
