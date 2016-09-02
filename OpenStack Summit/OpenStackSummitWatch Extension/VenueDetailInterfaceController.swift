//
//  VenueDetailInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class VenueDetailInterfaceController: WKInterfaceController {
    
    static let identifier = "VenueDetail"
    
    // MARK: - IB Outlets
    
    // MARK: - Properties
    
    private(set) var venue: Venue!
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let venue = (context as? Context<Venue>)?.value
            else { fatalError("Invalid context") }
        
        self.venue = venue
        
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
    
    
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        
    }
}
