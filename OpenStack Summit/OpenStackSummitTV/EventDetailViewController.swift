//
//  EventDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/5/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

@objc(OSSTVEventDetailViewController)
final class EventDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    var event: Identifier!
    
    private var eventCache: Event!
    
    private var eventDetail: EventDetail!
    
    private var data = [Detail]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        assert(event != nil, "No identifier set")
        
        guard let realmEvent = RealmSummitEvent.find(event, realm: Store.shared.realm)
            else { fatalError("Invalid event \(event)") }
        
        self.eventCache = Event(realmEntity: realmEvent)
        self.eventDetail = EventDetail(realmEntity: realmEvent)
        
        self.data = [Detail]()
        
        data.append(.name(eventDetail.name))
        
        if eventDetail.track.isEmpty == false {
            
            data.append(.track(eventDetail.track))
        }
        
        
        
        // reload table
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let detail = self.data[indexPath.row]
        
        switch detail {
            
        case let .name(name):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventNameCell", forIndexPath: indexPath)
            
            cell.textLabel!.text = name
            
            return cell
            
        case let .track(name):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventTrackCell", forIndexPath: indexPath)
            
            cell.textLabel!.text = name
            
            return cell
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showTrackEvents":
            
            let predicate = NSPredicate(format: "presentation.track.id == %@", eventCache.presentation!.track! as NSNumber)
                        
            let eventsViewController = segue.destinationViewController as! EventsViewController
            
            eventsViewController.predicate = predicate
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}

// MARK: - Supporting Types

private extension EventDetailViewController {
    
    enum Detail {
        
        case name(String)
        case track(String)
    }
}
