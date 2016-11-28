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
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let summitPredicate = NSPredicate(format: "summit.id == %@", summitID)
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate, summitPredicate, EventsViewController.cachedPredicate])
        
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
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let updateIndexPath = indexPath,
                let cell = self.tableView.cellForRowAtIndexPath(updateIndexPath) {
                
                self.configure(cell: cell, at: updateIndexPath)
            }
        case .Move:
            
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: .Fade)
            }
            
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .Fade)
            }
        }
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
