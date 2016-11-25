//
//  VenueDirectoryViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SwiftFoundation
import CoreSummit
import CoreData

@objc(OSSTVVenueDirectoryViewController)
final class VenueDirectoryViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    private var mapViewController: VenueMapViewController!
    
    private var lastSelectedIndexPath: NSIndexPath?
    
    private let delayedSeguesOperationQueue = NSOperationQueue()
    
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
        
        updateUI()
        
        // show map view controller
        performSegueWithIdentifier("showVenueMap", sender: self)
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        self.title = "Venues"
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let summitPredicate = NSPredicate(format: "summit.id == %@", summitID)
        
        self.fetchedResultsController = NSFetchedResultsController(Venue.self, delegate: self, predicate: summitPredicate, sortDescriptors: VenueManagedObject.sortDescriptors, sectionNameKeyPath: "isInternal", context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        tableView.reloadData()
    }
    
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let venue = self[indexPath]
        
        cell.textLabel!.text = venue.name
    }
    
    private subscript (indexPath: NSIndexPath) -> Venue {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! VenueManagedObject
        
        return Venue(managedObject: managedObject)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = self.fetchedResultsController.sections![section]
        
        return section.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("VenueTableViewCell", forIndexPath: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .Internal: return nil
        case .External: return "External Venues"
        }
    }
        
    override func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        // Check that the next focus view is a child of the table view.
        guard let nextFocusedView = context.nextFocusedView where nextFocusedView.isDescendantOfView(tableView) else { return }
        guard let indexPath = context.nextFocusedIndexPath else { return }
        
        // Cancel any previously queued segues.
        delayedSeguesOperationQueue.cancelAllOperations()
        
        // Create an `NSBlockOperation` to perform the detail segue after a delay.
        let performSegueOperation = NSBlockOperation()
        
        performSegueOperation.addExecutionBlock { [weak self, unowned performSegueOperation] in
            
            guard let controller = self else { return }
            
            // Pause the block so the segue isn't immediately performed.
            NSThread.sleepForTimeInterval(0.1)
            
            /*
             Check that the operation wasn't cancelled and that the segue identifier
             is different to the last performed segue identifier.
             */
            guard performSegueOperation.cancelled == false
                && indexPath != controller.lastSelectedIndexPath
                else { return }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
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
            
        case "showVenueMap":
            
            self.mapViewController = segue.destinationViewController as! VenueMapViewController
            
        case "showVenueDetail":
            
            let venue = self[tableView.indexPathForSelectedRow!]
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let venueDetailViewController = navigationController.topViewController as! VenueDetailViewController
            
            venueDetailViewController.location = .venue(venue)
            
            //venueDetailViewController.canShowMap = false
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}


// MARK: - Supporting Types

private extension VenueDirectoryViewController {
    
    enum Section: Int {
        
        static let count = 2
        
        case Internal, External
    }
}
