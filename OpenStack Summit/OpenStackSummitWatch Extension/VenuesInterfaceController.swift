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
        
        let allVenues = Store.shared.cache?.locations.reduce([Venue](), combine: {
            
            guard case let .venue(venue) = $1
                else { return $0 }
            
            var venues = $0
            venues.append(venue)
            
            return venues
            
        }) ?? []
        
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
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
                let imageURL = NSURL(string: image.url),
                let imageData = NSData(contentsOfURL: imageURL) {
                
                cell.imageView.setHidden(false)
                cell.imageView.setImageData(imageData)
                
            } else {
                
                cell.imageView.setHidden(true)
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
}
