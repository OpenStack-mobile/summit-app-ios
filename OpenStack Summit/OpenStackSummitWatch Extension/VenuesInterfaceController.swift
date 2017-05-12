//
//  VenuesInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class VenuesInterfaceController: WKInterfaceController {
    
    static let identifier = "Venues"
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: WKInterfaceTable!
    
    // MARK: - Properties
    
    let venues: [Venue] = {
        
        let allVenues = Store.shared.cache?.locations.reduce([Venue](), {
            
            guard case let .venue(venue) = $1
                else { return $0 }
            
            var venues = $0
            venues.append(venue)
            
            return venues
            
        }) ?? []
        
        let internalVenues = allVenues.filter({ $0.isInternal }).sorted { $0.0.name > $0.1.name }
        
        let externalVenues = allVenues.filter({ $0.isInternal == false }).sorted { $0.0.name > $0.1.name }
        
        return internalVenues + externalVenues
    }()
    
    // MARK: - Loading
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /// set user activity
        if let summit = Store.shared.cache {
            
            updateUserActivity(AppActivity.screen.rawValue, userInfo: [AppActivityUserInfo.screen.rawValue: AppActivityScreen.venues.rawValue], webpageURL: summit.webpage.appendingPathComponent("travel"))
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Segue
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        let venue = venues[rowIndex]
        
        return Context(Location.venue(venue))
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        tableView.setNumberOfRows(venues.count, withRowType: VenueCellController.identifier)
        
        for (index, venue) in venues.enumerated() {
            
            let cell = tableView.rowController(at: index) as! VenueCellController
            
            // set content
            
            cell.nameLabel.setText(venue.name)
            cell.addressLabel.setText(venue.fullAddress)
            
            if let imageURL = venue.images.sorted().first?.url {
                
                // show activity indicator
                cell.activityIndicator.setImageNamed("Activity")
                cell.activityIndicator.startAnimatingWithImages(in: NSRange(location: 0, length: 30), duration: 1.0, repeatCount: 0)
                cell.activityIndicator.setHidden(false)
                cell.imageView.setHidden(true)
                
                // load image
                cell.imageView.loadCached(imageURL) { (response) in
                    
                    // hide activity indicator
                    cell.activityIndicator.setHidden(true)
                    
                    // hide image view if no image
                    guard case .data = response else {
                        
                        cell.imageView.setHidden(true)
                        return
                    }
                    
                    cell.imageView.setHidden(false)
                }
                
            } else {
                
                cell.imageView.setHidden(true)
                cell.activityIndicator.setHidden(true)
            }
            
            // set header visibility
            let headerVisible = index != 0 && venues[index - 1].isInternal != venue.isInternal
            cell.headerGroup.setHidden(headerVisible == false)
        }
    }
}

// MARK: - Supporting Types

final class VenueCellController: NSObject {
    
    static let identifier = "VenueCell"
    
    @IBOutlet private(set) weak var headerGroup: WKInterfaceGroup!
    
    @IBOutlet private(set) weak var contentGroup: WKInterfaceGroup!
    
    @IBOutlet private(set) weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var addressLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var imageView: WKInterfaceImage!
    
    @IBOutlet private(set) weak var activityIndicator: WKInterfaceImage!
}
