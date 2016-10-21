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
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    // MARK: - Properties
    
    let venues: [Venue] = {
        
        let allVenues = Venue.from(realm: Store.shared.realm.objects(RealmVenue))
        
        let internalVenues = allVenues.filter({ $0.isInternal }).sort { $0.0.name > $0.1.name }
        
        let externalVenues = allVenues.filter({ $0.isInternal == false }).sort { $0.0.name > $0.1.name }
        
        return internalVenues + externalVenues
    }()
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /// set user activity
        if let summit = Store.shared.realm.objects(RealmSummit).first {
            
            updateUserActivity(AppActivity.screen.rawValue, userInfo: [AppActivityUserInfo.screen.rawValue: AppActivityScreen.venues.rawValue], webpageURL: NSURL(string: summit.webpageURL + "/travel"))
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Segue
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        let venue = venues[rowIndex]
        
        return Context(Location.venue(venue))
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        tableView.setNumberOfRows(venues.count, withRowType: VenueCellController.identifier)
        
        for (index, venue) in venues.enumerate() {
            
            let cell = tableView.rowControllerAtIndex(index) as! VenueCellController
            
            // set content
            
            cell.nameLabel.setText(venue.name)
            cell.addressLabel.setText(venue.fullAddress)
            
            if let image = venue.images.first,
                let imageURL = NSURL(string: image.url) {
                
                // show activity indicator
                cell.activityIndicator.setImageNamed("Activity")
                cell.activityIndicator.startAnimatingWithImagesInRange(NSRange(location: 0, length: 30), duration: 1.0, repeatCount: 0)
                cell.activityIndicator.setHidden(false)
                cell.imageView.setHidden(true)
                
                // load image
                cell.imageView.loadCached(imageURL) { (response) in
                    
                    // hide activity indicator
                    cell.activityIndicator.setHidden(true)
                    
                    // hide image view if no image
                    guard case .Data = response else {
                        
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
    
    @IBOutlet weak var headerGroup: WKInterfaceGroup!
    
    @IBOutlet weak var contentGroup: WKInterfaceGroup!
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var addressLabel: WKInterfaceLabel!
    
    @IBOutlet weak var imageView: WKInterfaceImage!
    
    @IBOutlet weak var activityIndicator: WKInterfaceImage!
}
