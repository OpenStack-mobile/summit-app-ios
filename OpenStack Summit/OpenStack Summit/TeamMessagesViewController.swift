//
//  TeamMessagesViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit

final class TeamMessagesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var team: Identifier? {
        
        didSet { if isViewLoaded() { configureView() } }
    }
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        if let team = self.team,
            let teamManagedObject = try! TeamManagedObject.find(team, context: Store.shared.managedObjectContext) {
            
            self.title = teamManagedObject.name
            
            let predicate = NSPredicate(format: "team == %@", teamManagedObject)
            
            let sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
            
            self.fetchedResultsController = NSFetchedResultsController(TeamMessage.self,
                                                                       delegate: self,
                                                                       predicate: predicate,
                                                                       sortDescriptors: sortDescriptors,
                                                                       sectionNameKeyPath: nil,
                                                                       context: Store.shared.managedObjectContext)
            
            try! self.fetchedResultsController!.performFetch()
            
        } else {
            
            self.title = ""
            
            self.fetchedResultsController = nil
        }
        
        self.tableView.reloadData()
    }
    
    private subscript (indexPath: NSIndexPath) -> TeamMessage {
        
        let managedObject = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! TeamMessageManagedObject
        
        return TeamMessage(managedObject: managedObject)
    }
    
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let message = self[indexPath]
        
        cell.textLabel!.text = message.body
        
        cell.detailTextLabel!.text = message.created.toFoundation().description
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamCell)!
        
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
}
