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
    
    static let identifier = "Events"
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: WKInterfaceTable!
    
    // MARK: - Properties
    
    private(set) var events = [Event]()
    
    private static let dateFormatter: DateFormatter = {
       
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: Store.shared.cache!.timeZone)
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    // MARK: - Loading
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        events = (context as? Context<[Event]?>)?.value ?? Store.shared.cache!.schedule.sorted()
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /// set user activity
        if let summit = Store.shared.cache {
            
            updateUserActivity(AppActivity.screen.rawValue, userInfo: [AppActivityUserInfo.screen.rawValue: AppActivityScreen.events.rawValue], webpageURL: summit.webpage.appendingPathComponent("summit-schedule"))
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        // configure cells
        
        tableView.setNumberOfRows(events.count, withRowType: EventCellController.identifier)
        
        for (index, event) in events.enumerated() {
            
            let cell = tableView.rowController(at: index) as! EventCellController
            
            let dateText = EventsInterfaceController.dateFormatter.string(from: event.start)
            let locationText = EventDetail.getLocation(event, summit: Store.shared.cache!)
            
            cell.nameLabel.setText(event.name)
            cell.dateLabel.setText(" " + dateText)
            cell.locationLabel.setText(locationText)
            cell.locationGroup.setHidden(locationText.isEmpty)
        }
    }
    
    // MARK: - Segue
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        let event = events[rowIndex]
        
        return Context(event)
    }
}

// MARK: - Supporting Types

final class EventCellController: NSObject {
    
    static let identifier = "EventCell"
    
    @IBOutlet private(set) weak var nameLabel: WKInterfaceLabel!
    @IBOutlet private(set) weak var dateLabel: WKInterfaceLabel!
    @IBOutlet private(set) weak var locationLabel: WKInterfaceLabel!
    @IBOutlet private(set) weak var locationGroup: WKInterfaceGroup!
}
