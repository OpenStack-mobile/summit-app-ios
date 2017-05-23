//
//  VenueDirectoryViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import Foundation
import CoreSummit
import CoreData
import Predicate

@objc(OSSTVVenueDirectoryViewController)
final class VenueDirectoryViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController<VenueManagedObject>!
    
    private var mapViewController: VenueMapViewController!
    
    private var lastSelectedIndexPath: IndexPath?
    
    private let delayedSeguesOperationQueue = OperationQueue()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Set `remembersLastFocusedIndexPath` to `true` to ensure the same row
         becomes focused whenever focus is returned to the table view.
         */
        tableView.remembersLastFocusedIndexPath = true
        
        /*
         Adjust the layout margins of the `tableView` to add a horizontal inset
         to the cells. This will allow for overscan on older TVs and space for
         the focus effect.
         */
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 20
        
        // show map view controller
        performSegue(withIdentifier: "showVenueMap", sender: self)
        
        // setup fetched results controller
                
        //let predicate = NSPredicate(format: "(latitude != nil AND longitude != nil) AND summit.id == %@", summitID)
        let predicate: Predicate = .keyPath(#keyPath(VenueManagedObject.latitude)) != .value(.null)
            && .keyPath(#keyPath(VenueManagedObject.longitude)) != .value(.null)
            && #keyPath(VenueManagedObject.summit.id) == SummitManager.shared.summit.value
        
        let sort = [NSSortDescriptor(key: #keyPath(VenueManagedObject.venueType), ascending: true),
                    NSSortDescriptor(key: #keyPath(VenueManagedObject.name), ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(Venue.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sort,
                                                                   sectionNameKeyPath: #keyPath(VenueManagedObject.venueType),
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        self.title = self.isDataLoaded ? "Venues" : "Loading..."
    }
    
    private func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        
        let venue = self[indexPath]
        
        cell.textLabel!.text = venue.name
    }
    
    private subscript (indexPath: IndexPath) -> Venue {
        
        let managedObject = self.fetchedResultsController.object(at: indexPath) as! VenueManagedObject
        
        return Venue(managedObject: managedObject)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = self.fetchedResultsController.sections![section]
        
        return section.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableViewCell", for: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sectionString = self.fetchedResultsController.sections?[section].name,
            let locationType = Venue.LocationType(rawValue: sectionString)
            else { return nil }
        
        switch locationType {
        case .External: return "External Venues"
        case .Internal: return nil
        case .None: return nil
        }
    }
        
    override func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        // Check that the next focus view is a child of the table view.
        guard let nextFocusedView = context.nextFocusedView, nextFocusedView.isDescendant(of: tableView) else { return }
        guard let indexPath = context.nextFocusedIndexPath else { return }
        
        // Cancel any previously queued segues.
        delayedSeguesOperationQueue.cancelAllOperations()
        
        // Create an `NSBlockOperation` to perform the detail segue after a delay.
        let performSegueOperation = BlockOperation()
        
        performSegueOperation.addExecutionBlock { [weak self, unowned performSegueOperation] in
            
            guard let controller = self else { return }
            
            // Pause the block so the segue isn't immediately performed.
            Thread.sleep(forTimeInterval: 0.1)
            
            /*
             Check that the operation wasn't cancelled and that the segue identifier
             is different to the last performed segue identifier.
             */
            guard performSegueOperation.isCancelled == false
                && indexPath != controller.lastSelectedIndexPath
                else { return }
            
            OperationQueue.main.addOperation {
                
                // Record the last performed segue identifier.
                controller.lastSelectedIndexPath = indexPath
                
                /*
                 Select the focused cell so that the table view visibly reflects
                 which detail view is being shown.
                 */
                let selectedVenue = controller[indexPath]
                
                if selectedVenue.location != nil {
                    
                    controller.mapViewController.selectedVenue = selectedVenue.identifier
                }
            }
        }
        
        delayedSeguesOperationQueue.addOperation(performSegueOperation)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView.endUpdates()
        
        self.updateUI()
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            
        case .delete:
            
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            
        default: break
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case "showVenueMap":
            
            self.mapViewController = segue.destination as! VenueMapViewController
            
        case "showVenueDetail":
            
            let venue = self[tableView.indexPathForSelectedRow!]
            
            let navigationController = segue.destination as! UINavigationController
            
            let venueDetailViewController = navigationController.topViewController as! VenueDetailViewController
            
            venueDetailViewController.location = .venue(venue)
            
            //venueDetailViewController.canShowMap = false
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}
