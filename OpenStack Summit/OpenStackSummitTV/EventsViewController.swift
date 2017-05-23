//
//  EventsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import Foundation
import CoreSummit
import CoreData
import Predicate

@objc(OSSTVEventsViewController)
final class EventsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var predicate = Predicate.value(false) {
        
        didSet { if isViewLoaded { updateUI() } }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<EventManagedObject>!
    
    private static let cachedPredicate: Predicate = (.keyPath(#keyPath(Entity.cached)) != .value(.null))
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 90
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        // NSPredicate(format: "summit.id == %@", summitID)
        let summitPredicate: Predicate = #keyPath(EventManagedObject.summit.id) == SummitManager.shared.summit.value
        
        let predicate: Predicate = .compound(.and([self.predicate, summitPredicate, EventsViewController.cachedPredicate]))
        
        self.fetchedResultsController = NSFetchedResultsController(Event.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: EventManagedObject.sortDescriptors,
                                                                   context: Store.shared.managedObjectContext)
        
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 20
        
        try! self.fetchedResultsController.performFetch()
        
        tableView.reloadData()
    }
    
    private func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        
        let event = self[indexPath]
        
        cell.textLabel!.text = event.name
    }
    
    private subscript (indexPath: IndexPath) -> Event {
        
        let managedObject = self.fetchedResultsController.object(at: indexPath) as! EventManagedObject
        
        return Event(managedObject: managedObject)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        case .delete:
            
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
        case .update:
            if let updateIndexPath = indexPath,
                let cell = self.tableView.cellForRow(at: updateIndexPath) {
                
                self.configure(cell: cell, at: updateIndexPath)
            }
        case .move:
            
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
            
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case "showEventDetail":
            
            let event = self[tableView.indexPathForSelectedRow!]
            
            let navigationController = segue.destination as! UINavigationController
            
            let eventDetailViewController = navigationController.topViewController as! EventDetailViewController
            
            eventDetailViewController.event = event.identifier
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}
