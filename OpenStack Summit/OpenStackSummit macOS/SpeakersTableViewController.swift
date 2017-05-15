//
//  SpeakersTableViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/21/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit
import Predicate

final class SpeakersTableViewController: TableViewController {
    
    // MARK: - Properties
    
    var predicate = Predicate.value(false) {
        
        didSet { configureView() }
    }
    
    private lazy var cachedPredicate: Predicate = (.keyPath(#keyPath(Entity.cached)) != .value(.null))
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func tableViewClick(_ sender: AnyObject) {
        
        guard tableView.selectedRow >= 0
            else { return }
        
        defer { tableView.deselectAll(sender) }
        
        let speaker = fetchedResultsController.fetchedObjects![tableView.selectedRow] as! SpeakerManagedObject
        
        AppDelegate.shared.mainWindowController.view(data: .speaker, identifier: speaker.id)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let _ = self.view
        
        assert(isViewLoaded)
        
        let predicate: Predicate = .compound(.and([self.predicate, cachedPredicate]))
        
        self.fetchedResultsController = NSFetchedResultsController(Speaker.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: SpeakerManagedObject.sortDescriptors,
                                                                   context: Store.shared.managedObjectContext) as! NSFetchedResultsController<Entity>
        
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 10
        
        try! self.fetchedResultsController.performFetch()
        
        tableView.reloadData()
        
        // scroll to top
        if tableView.numberOfRows > 0 {
            
            tableView.scrollRowToVisible(0)
        }
    }
    
    private func configure(cell: SpeakerTableViewCell, at row: Int) {
        
        let managedObject = self.fetchedResultsController.fetchedObjects![row] as! SpeakerManagedObject
        
        let speaker = Speaker(managedObject: managedObject)
        
        cell.nameLabel.stringValue = speaker.name
        
        cell.titleLabel.isHidden = speaker.title == nil
        cell.titleLabel.stringValue = speaker.title ?? ""
        
        cell.imageView!.image = #imageLiteral(resourceName: "generic-user-avatar")
        
        cell.imageView!.loadCached(speaker.picture)
    }
    
    // MARK: - NSTableViewDataSource
    
    func tableView(_ tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! SpeakerTableViewCell
        
        configure(cell: cell, at: row)
        
        return cell
    }
}

// MARK: - Supporting Types

final class SpeakerTableViewCell: NSTableCellView {
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var titleLabel: NSTextField!
}
