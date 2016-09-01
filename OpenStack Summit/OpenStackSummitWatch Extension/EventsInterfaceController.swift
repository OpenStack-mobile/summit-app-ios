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
    
    typealias Filter = (Event) -> Bool
    
    static let identifier = "Events"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    // MARK: - Properties
    
    private var events = [Event]()
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        var filter: Filter = { _ in return true }
        
        if let context = context as? Context<Filter> {
            
            filter = context.value
        }
        
        updateUI(filter)
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
    
    private func updateUI(filter: Filter) {
        
        // filter events
        
        let allEvents = cachedSummit?.schedule ?? []
        
        events = allEvents.filter(filter)
        
        // configure cells
        
        tableView.setNumberOfRows(events.count, withRowType: EventCellController.identifier)
        
        for (index, event) in events.enumerate() {
            
            let cell = tableView.rowControllerAtIndex(index) as! EventCellController
            
            cell.eventLabel.setText(event.name)
        }
    }
    
    // MARK: - Segue
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        let event = events[rowIndex]
        
        return Context(event)
    }
}

// MARK: - Supporting Types

final class EventCellController: NSObject {
    
    static let identifier = "EventCell"
    
    @IBOutlet weak var eventLabel: WKInterfaceLabel!
}
