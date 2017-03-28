//
//  NotificationDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

final class NotificationDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    var notification: Notification!
    
    private var data = [[Data]]()
    
    private lazy var dateFormatter: NSDateFormatter = {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = .LongStyle
        
        dateFormatter.timeStyle = .MediumStyle
        
        return dateFormatter
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        assert(isViewLoaded(), "View must be loaded")
        
        assert(self.notification != nil, "\(self) not configured with notification")
        
        data = []
        
        if let eventID = self.notification.event,
            let event = try! Event.find(eventID, context: Store.shared.managedObjectContext) {
            
            data.append([.event(event)])
        }
        
        let date = dateFormatter.stringFromDate(notification.created.toFoundation())
        
        let text = notification.body
        
        data.append([.date(date), .text(text)])
                
        // mark notification as read
        PushNotificationManager.shared.unreadNotifications.value.remove(notification.identifier)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return data.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = data[section]
        
        return section.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = self.data[indexPath.section][indexPath.row]
        
        switch data {
            
        case let .event(event):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.notificationDetailEventCell, forIndexPath: indexPath)!
            
            cell.textLabel!.text = event.name
            
            return cell
            
        case let .date(date):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.notificationDetailDateCell, forIndexPath: indexPath)!
            
            cell.textLabel!.text = date
            
            return cell
            
        case let .text(text):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.notificationDetailTextCell, forIndexPath: indexPath)!
            
            cell.textLabel!.text = text
            
            return cell
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case R.segue.notificationDetailViewController.showNotificationEvent.identifier:
            
            guard let event = self.notification?.event
                else { fatalError("No event for notification") }
            
            let eventViewController = segue.destinationViewController as! EventDetailViewController
            
            eventViewController.event = event
            
        default: fatalError()
        }
    }
}

// MARK: - Supporting Types

private extension NotificationDetailViewController {
    
    enum Data {
        
        case event(Event)
        case date(String)
        case text(String)
    }
}
