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
import CoreData

@objc(OSSTVEventsViewController)
final class EventsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var predicate = NSPredicate(value: false) {
        
        didSet { if isViewLoaded() { updateUI() } }
    }
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    private static let cachedPredicate = NSPredicate(format: "cached != nil")
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 90
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate, EventsViewController.cachedPredicate])
        
        self.fetchedResultsController = NSFetchedResultsController(Event.self, delegate: self, predicate: predicate, sortDescriptors: EventManagedObject.sortDescriptors, context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        tableView.reloadData()
    }
    
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let event = self[indexPath]
        
        cell.textLabel!.text = event.name
    }
    
    private subscript (indexPath: NSIndexPath) -> Event {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! EventManagedObject
        
        return Event(managedObject: managedObject)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
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
            
            let event = self[tableView.indexPathForSelectedRow!]
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let eventDetailViewController = navigationController.topViewController as! EventDetailViewController
            
            eventDetailViewController.event = event.identifier
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}
