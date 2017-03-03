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
        
        didSet { configureView() }
    }
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    private lazy var cachedPredicate = NSPredicate(format: "cached != nil")
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func tableViewClick(sender: AnyObject) {
        
        guard tableView.selectedRow >= 0
            else { return }
        
        defer { tableView.deselectAll(sender) }
        
        let event = fetchedResultsController.fetchedObjects![tableView.selectedRow] as! EventManagedObject
        
        AppDelegate.shared.mainWindowController.view(.event, identifier: event.identifier)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
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
        
        // scroll to top
        if tableView.numberOfRows > 0 {
            
            tableView.scrollRowToVisible(0)
        }
    }
    
    private func configure(cell cell: EventTableViewCell, at row: Int) {
        
        let eventManagedObject = self.fetchedResultsController.fetchedObjects![row] as! EventManagedObject
        
        let eventDetail = ScheduleItem(managedObject: eventManagedObject)
        
        cell.nameLabel.stringValue = eventDetail.name
        cell.dateTimeLabel.stringValue = eventDetail.dateTime
        cell.locationLabel.stringValue = eventDetail.location
        cell.trackLabel.stringValue = eventDetail.track
        cell.typeLabel.stringValue = eventDetail.eventType
        cell.trackGroupColorView.fillColor = NSColor(hexString: eventDetail.trackGroupColor) ?? NSColor.clearColor()
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! EventTableViewCell
        
        configure(cell: cell, at: row)
        
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
        
    @IBOutlet private(set) weak var dateTimeLabel: NSTextField!
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var locationLabel: NSTextField!
    
    @IBOutlet private(set) weak var trackLabel: NSTextField!
    
    @IBOutlet private(set) weak var typeLabel: NSTextField!
    
    @IBOutlet private(set) weak var trackGroupColorView: NSBox!
}
