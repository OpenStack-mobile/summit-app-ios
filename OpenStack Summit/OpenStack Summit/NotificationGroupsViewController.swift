//
//  NotificationGroupsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit

final class NotificationGroupsViewController: UITableViewController, NSFetchedResultsControllerDelegate, RevealViewController {
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        self.fetchedResultsController = NSFetchedResultsController(NotificationGroup.self,
                                                                   delegate: self,
                                                                   predicate: nil,
                                                                   sortDescriptors: NotificationGroupManagedObject.sortDescriptors,
                                                                   sectionNameKeyPath: nil,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        self.tableView.reloadData()
    }
    
    private subscript (indexPath: NSIndexPath) -> NotificationGroup {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NotificationGroupManagedObject
        
        return NotificationGroup(managedObject: managedObject)
    }
    
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let notificationGroup = self[indexPath]
        
        cell.textLabel!.text = notificationGroup.name
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.notificationGroupCell)!
        
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
            
        case R.segue.notificationGroupsViewController.showNotificationGroup.identifier: 
            
            let groupDetailViewController = segue.destinationViewController as! NotificationGroupDetailViewController
            
            // configure view controller
            
            let selectedGroup = self[self.tableView.indexPathForSelectedRow!]
            
            groupDetailViewController.group = selectedGroup.identifier
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}
