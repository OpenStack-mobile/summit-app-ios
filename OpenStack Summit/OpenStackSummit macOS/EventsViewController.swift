//
//  EventsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/19/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

final class EventsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: NSTableView!
    
    // MARK: - Properties
    
    var predicate = NSPredicate(value: false) {
        
        didSet { updateUI() }
    }
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    private lazy var cachedPredicate = NSPredicate(format: "cached != nil")
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let summitPredicate = NSPredicate(format: "summit.id == %@", summitID)
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate, summitPredicate, cachedPredicate])
        
        self.fetchedResultsController = NSFetchedResultsController(Event.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: EventManagedObject.sortDescriptors,
                                                                   context: Store.shared.managedObjectContext)
        
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 50
        
        try! self.fetchedResultsController.performFetch()
        
        tableView.reloadData()
    }
    
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let event = self[indexPath]
        
        cell.textLabel!.text = event.name
    }
    
    private subscript (indexPath: NSIndexPath) -> EventDetail {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! EventManagedObject
        
        return EventDetail(managedObject: managedObject)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: NSTableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(tableView: NSTableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(EventTableViewCell.identifier, forIndexPath: indexPath) as! EventTableViewCell
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        //self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //self.tableView.endUpdates()
        
        self.tableView.reloadData()
    }
    
    /*
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
    }*/
}

// MARK: - Supporting Types

final class EventTableViewCell: NSTableCellView {
    
    static let identifier = "EventTableViewCell"
    
    @IBOutlet weak var dateTimeLabel: NSTextView!
    
    @IBOutlet weak var nameLabel: NSTextView!
}
