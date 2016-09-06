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
import RealmSwift
import RealmResultsController

final class EventsViewController: UITableViewController, RealmResultsControllerDelegate {
    
    // MARK: - Properties
    
    var state: State = .empty("Events", "No selection") {
        
        didSet {
            
            if isViewLoaded() {
                
                updateUI()
            }
        }
    }
    
    private var resultsController: RealmResultsController<RealmSummitEvent, SummitEvent>?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        switch state {
            
        case let .empty(title, _ /* body */ ):
            
            resultsController = nil
            
            self.title = title
            
            // TODO: Set empty selection body
            
        case let .events(request):
            
            let resultsController = try! RealmResultsController(request: request, sectionKeyPath: nil, mapper: { SummitEvent(realmEntity: $0) })
            
            self.resultsController = resultsController
            
            resultsController.delegate = self
            
            resultsController.performFetch()
            
        }
        
        tableView.reloadData()
    }
    
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let event = resultsController!.objectAt(indexPath)
        
        assert(event.name.isEmpty == false, "Empty event name: \(event)")
        
        cell.textLabel!.text = event.name
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resultsController?.numberOfObjectsAt(section) ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("EventTableViewCell", forIndexPath: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - RealmResultsControllerDelegate
    
    func willChangeResults(controller: AnyObject) {
        
        tableView.beginUpdates()
    }
    
    func didChangeResults(controller: AnyObject) {
        
        tableView.endUpdates()
    }
    
    func didChangeObject<U>(controller: AnyObject, object: U, oldIndexPath: NSIndexPath, newIndexPath: NSIndexPath, changeType: RealmResultsChangeType) {
        
        switch changeType {
            
        case .Insert:
            
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            
        case .Delete:
            
            tableView.deleteRowsAtIndexPaths([oldIndexPath], withRowAnimation: .Automatic)
            
        case .Update:
            
            if let cell = tableView.cellForRowAtIndexPath(oldIndexPath) {
                
                configure(cell: cell, at: oldIndexPath)
            }
            
        case .Move:
            
            tableView.deleteRowsAtIndexPaths([oldIndexPath], withRowAnimation: .Automatic)
            
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        }
    }
    
    func didChangeSection<U>(controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType) {
        
        
    }
}

// MARK: - Supporting Types

extension EventsViewController {
    
    enum State {
        
        // The view controller needs to configured.
        case empty(String, String)
        case events(RealmRequest<RealmSummitEvent>)
    }
}
