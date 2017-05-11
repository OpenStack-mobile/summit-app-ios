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
    
    fileprivate var data = [[Data]]()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .long
        
        dateFormatter.timeStyle = .medium
        
        return dateFormatter
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func deleteAction(sender: UIBarButtonItem) {
        
        let context = Store.shared.privateQueueManagedObjectContext
        
        let identifier = self.notification.identifier
        
        func closeViewController() {
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.navigationController?.popViewControllerAnimated(true)
            }
        }
                
        context.performBlock {
            
            guard let notificationManagedObject = try! NotificationManagedObject.find(identifier, context: context)
                else { closeViewController(); return }
            
            context.deleteObject(notificationManagedObject)
            
            try! context.save()
            
            closeViewController()
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate func configureView() {
        
        assert(isViewLoaded, "View must be loaded")
        
        assert(self.notification != nil, "\(self) not configured with notification")
        
        data = []
        
        if let eventID = self.notification.event,
            let event = try! Event.find(eventID, context: Store.shared.managedObjectContext) {
            
            data.append([.event(event)])
        }
        
        let date = dateFormatter.stringFromDate(notification.created)
        
        let text = notification.body
        
        data.append([.date(date), .text(text)])
                
        // mark notification as read
        PushNotificationManager.shared.unreadNotifications.value.remove(notification.identifier)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = data[section]
        
        return section.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case R.segue.notificationDetailViewController.showNotificationEvent.identifier:
            
            guard let event = self.notification?.event
                else { fatalError("No event for notification") }
            
            let eventViewController = segue.destination as! EventDetailViewController
            
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
