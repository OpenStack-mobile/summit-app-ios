//
//  RoomDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class RoomDetailInterfaceController: WKInterfaceController {
    
    static let identifier = "RoomDetail"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var capacityLabel: WKInterfaceLabel!
    
    @IBOutlet weak var capacitySeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var venueLabel: WKInterfaceLabel!
    
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    
    // MARK: - Properties
    
    private(set) var room: VenueRoom!
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let room = (context as? Context<VenueRoom>)?.value
            else { fatalError("Invalid context") }
        
        self.room = room
        
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
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        
        switch segueIdentifier {
            
        case "RoomShowVenue":
            
        guard let venue = Store.shared.cache?.locations.with(room.venue)?.rawValue as? Venue
            else { fatalError("No venue \(room.venue) in cache") }
            
        return Context(venue)
            
        default: return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        guard let venue = Store.shared.cache?.locations.with(room.venue)?.rawValue as? Venue
            else { fatalError("Invalid venue \(room.venue)") }
        
        nameLabel.setText(venue.name + " - " + room.name)
        
        descriptionLabel.setText(room.descriptionText)
        descriptionLabel.setHidden(room.descriptionText == nil)
        
        if let capacity = room.capacity {
            
            capacityLabel.setText("\(capacity) capacity")
            capacityLabel.setHidden(false)
            capacitySeparator.setHidden(false)
            
        } else {
            
            capacityLabel.setHidden(true)
            capacitySeparator.setHidden(true)
        }
        
        self.venueLabel.setText(venue.name)
    }
}
