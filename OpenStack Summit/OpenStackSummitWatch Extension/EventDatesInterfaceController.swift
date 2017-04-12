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
    
    fileprivate(set) var dates = [Date]()
    
    fileprivate static let dateFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMMM d"
        
        return dateFormatter
    }()
    
    // MARK: - Loading
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
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
    
    fileprivate func updateUI() {
        
        // load dates
        
        let summit = Store.shared.cache!
        
        let dayCount = summit.end.toFoundation().mt_daysSinceDate(summit.start.toFoundation())
        
        self.dates = [Date]()
        
        for index in 0 ..< dayCount {
            
            let date = summit.start.toFoundation().mt_dateDaysAfter(index)
            
            dates.append(date)
        }
        
        // configure table view
        
        tableView.setNumberOfRows(dates.count, withRowType: LabelCellController.identifier)
        
        for (index, date) in dates.enumerated() {
            
            let cell = tableView.rowController(at: index) as! LabelCellController
            
            let dateText = EventDatesInterfaceController.dateFormatter.string(from: date)
            
            cell.textLabel.setText(dateText)
        }
    }
    
    // MARK: - Segue
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        // get value for selected row
        
        let selectedDate = self.dates[rowIndex]
        
        // get events for date
        
        let startDate = (selectedDate as NSDate).mt_startOfCurrentDay()
        let endDate = (selectedDate as NSDate).mt_endOfCurrentDay()
        
        let events = Store.shared.cache?.schedule.filter({
            
            return $0.start.toFoundation().mt_isBetweenDate(startDate, andDate: endDate)
        })
        
        return Context(events)
    }
}
