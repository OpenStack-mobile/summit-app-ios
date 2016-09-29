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
    func showLocationDetail(location: Identifier) {
        
        let venue: Identifier
        
        if let realmVenue = RealmVenue.find(location, realm: Store.shared.realm) {
            
            venue = realmVenue.id
            
        } else if let realmVenueRoom = RealmVenueRoom.find(location, realm: Store.shared.realm) {
            
            venue = realmVenueRoom.venue.id
            
        } else {
            
            fatalError("Invalid location \(location)")
        }
        
        let venueDetailVC = R.storyboard.venue.venueDetailViewController()!
        
        venueDetailVC.venue = venue
        
        self.showViewController(venueDetailVC, sender: self)
    }
}