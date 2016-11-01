//
//  EventsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SwiftFoundation
import CoreSummit

@objc(OSSTVEventsViewController)
final class EventsViewController: UITableViewController {
    
    // MARK: - Properties
    
    var predicate = NSPredicate(value: false)
    
    private var events = [Event]()
    
    private var notificationToken: RealmSwift.NotificationToken?
    
    // MARK: - Loading
    
    deinit {
        
        notificationToken?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 90
        
        updateUI()
        
        notificationToken = Store.shared.realm.addNotificationBlock { _ in self.updateUI() }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        events = Event.from(realm: Store.shared.realm.objects(RealmSummitEvent).filter(predicate))
        
        tableView.reloadData()
    }
    
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let event = events[indexPath.row]
        
        cell.textLabel!.text = event.name
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("EventTableViewCell", forIndexPath: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showEventDetail":
            
            let event = events[tableView.indexPathForSelectedRow!.row]
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let eventDetailViewController = navigationController.topViewController as! EventDetailViewController
            
            eventDetailViewController.event = event.identifier
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}
