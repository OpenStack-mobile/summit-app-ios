//
//  EventsInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class EventsInterfaceController: WKInterfaceController {
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let summit = cachedSummit
            else { return }
        
        let events = summit.schedule
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}

// MARK: - Supporting Types

