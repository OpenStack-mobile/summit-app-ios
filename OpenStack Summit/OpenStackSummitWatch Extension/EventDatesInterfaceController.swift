//
//  EventDatesInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/21/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class EventDatesInterfaceController: WKInterfaceController {
    
    static let identifier = "EventDates"
    
    // MARK: - IB Outlets
    
     @IBOutlet weak var tableView: WKInterfaceTable!
    
    // MARK: - Properties
    
    private(set) var dates = [NSDate]()
    
    private static let dateFormatter: NSDateFormatter = {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "MMMM d"
        
        return dateFormatter
    }()
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updateUserActivity(AppActivity.screen.rawValue, userInfo: [AppActivityUserInfo.screen.rawValue: AppActivityScreen.events.rawValue], webpageURL: nil)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        // load dates
        
        let summit = Store.shared.realm.objects(RealmSummit).first!
        
        let dayCount = summit.endDate.mt_daysSinceDate(summit.startDate)
        
        self.dates = [NSDate]()
        
        for index in 0 ..< dayCount {
            
            let date = summit.startDate.mt_dateDaysAfter(index)
            
            dates.append(date)
        }
        
        // configure table view
        
        tableView.setNumberOfRows(dates.count, withRowType: LabelCellController.identifier)
        
        for (index, date) in dates.enumerate() {
            
            let cell = tableView.rowControllerAtIndex(index) as! LabelCellController
            
            let dateText = EventDatesInterfaceController.dateFormatter.stringFromDate(date)
            
            cell.textLabel.setText(dateText)
        }
    }
    
    // MARK: - Segue
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        // get value for selected row
        
        let selectedDate = self.dates[rowIndex]
        
        // get events for date
                
        let endDate = selectedDate.mt_endOfCurrentDay()
        
        let events = Store.shared.realm.objects(RealmSummitEvent).filter("start >= %@ AND end <= %@", selectedDate, endDate).map { $0.id }
        
        return Context(events)
    }
}