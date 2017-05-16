//
//  VenuesTableViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit
import Predicate

final class VenueDirectoryViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: NSTableView!
    
    // MARK: - Properties
    
    var predicate = Predicate.value(true) {
        
        didSet { configureView() }
    }
    
    weak var delegate: VenueDirectoryViewControllerDelegate?
    
    private var fetchedResultsController: NSFetchedResultsController<VenueManagedObject>!
    
    private var summitObserver: Int?
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = summitObserver {
            
            SummitManager.shared.summit.remove(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.configureView() }
        
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func tableViewClick(_ sender: AnyObject? = nil) {
        
        guard tableView.selectedRow >= 0
            else { return }
        
        defer { tableView.deselectAll(sender) }
        
        // get selected venue
        
        let venue = self.fetchedResultsController.fetchedObjects![tableView.selectedRow]
        
        delegate?.venueDirectoryViewController(self, didSelect: venue.id)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        //let summitPredicate = NSPredicate(format: "summit.id == %@", summitID)
        let summitPredicate: Predicate = #keyPath(VenueManagedObject.summit.id) == SummitManager.shared.summit.value
        
        let predicate: Predicate = .compound(.and([self.predicate, summitPredicate]))
        
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(Venue.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sort,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        self.tableView.reloadData()
    }
    
    private func configure(cell: VenueTableViewCell, at row: Int) {
        
        assert(fetchedResultsController.fetchedObjects != nil)
        
        let venueManagedObject = fetchedResultsController.fetchedObjects![row]
        
        let venue = VenueListItem(managedObject: venueManagedObject)
        
        cell.venueNameLabel.stringValue = venue.name
        cell.venueAddressLabel.stringValue = venue.address
        
        cell.imageURL = venue.backgroundImage
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    // MARK: - NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! VenueTableViewCell
        
        configure(cell: cell, at: row)
        
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        //self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
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
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .Insert:
            
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        case .Delete:
            
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        default: break
        }
    }*/
}

// MARK: - Supporting Types

@objc protocol VenueDirectoryViewControllerDelegate: class {
    
    func venueDirectoryViewController(_ controller: VenueDirectoryViewController, didSelect venue: Identifier)
}

final class VenueTableViewCell: ImageTableViewCell {
    
    @IBOutlet private(set) weak var venueNameLabel: NSTextField!
    
    @IBOutlet private(set) weak var venueAddressLabel: NSTextField!
}
