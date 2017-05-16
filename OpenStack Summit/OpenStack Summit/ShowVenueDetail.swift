//
//  ShowVenueDetail.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/26/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

extension UIViewController {
    
    /// Shows the approriate Venue detail VC for the specified venue.
    func show(location: Identifier) {
        
        let venue: Identifier
        
        if let venueManagedObject = try! VenueManagedObject.find(location, context: Store.shared.managedObjectContext) {
            
            venue = venueManagedObject.id
            
        } else if let venueRoomManagedObject = try! VenueRoomManagedObject.find(location, context: Store.shared.managedObjectContext) {
            
            venue = venueRoomManagedObject.venue.id
            
        } else {
            
            fatalError("Invalid location \(location)")
        }
        
        let venueDetailViewController = R.storyboard.venue.venueDetailViewController()!
        
        venueDetailViewController.venue = venue
        
        self.show(venueDetailViewController, sender: self)
    }
}
