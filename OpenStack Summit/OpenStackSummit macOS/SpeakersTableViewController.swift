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

final class SpeakersTableViewController: TableViewController {
    
    // MARK: - Properties
    
    var predicate = NSPredicate(value: false) {
        
        didSet { configureView() }
    }
    
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
        
        let speaker = fetchedResultsController.fetchedObjects![tableView.selectedRow] as! SpeakerManagedObject
        
        if let existingWindow = NSApp.windows.firstMatching({ ($0.windowController as? SpeakerWindowController)?.speaker == speaker.identifier }) {
            
            existingWindow.makeKeyAndOrderFront(nil)
            
        } else {
            
            self.performSegueWithIdentifier("showSpeaker", sender: nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let summitPredicate = NSPredicate(format: "summit.id == %@", summitID)
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate, summitPredicate, cachedPredicate])
        
        self.fetchedResultsController = NSFetchedResultsController(Speaker.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: SpeakerManagedObject.sortDescriptors,
                                                                   context: Store.shared.managedObjectContext)
        
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 10
        
        try! self.fetchedResultsController.performFetch()
        
        tableView.reloadData()
        
        // scroll to top
        if tableView.numberOfRows > 0 {
            
            tableView.scrollRowToVisible(0)
        }
    }
    
    private func configure(cell cell: SpeakerTableViewCell, at row: Int) {
        
        let managedObject = self.fetchedResultsController.fetchedObjects![row] as! SpeakerManagedObject
        
        let speaker = Speaker(managedObject: managedObject)
        
        cell.nameLabel.stringValue = speaker.name
        
        cell.titleLabel.hidden = speaker.title == nil
        cell.titleLabel.stringValue = speaker.title ?? ""
        
        cell.imageView!.image = NSImage(named: "generic-user-avatar")
        
        if let url = NSURL(string: speaker.pictureURL) {
            
            cell.imageView!.loadCached(url)
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! SpeakerTableViewCell
        
        configure(cell: cell, at: row)
        
        return cell
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showSpeaker":
            
            // get selected speaker
            let speaker = fetchedResultsController.fetchedObjects![tableView.selectedRow] as! SpeakerManagedObject
            
            // show window controller
            let windowController = segue.destinationController as! SpeakerWindowController
            windowController.speaker = speaker.identifier
            
        default: fatalError()
        }
    }
}

// MARK: - Supporting Types

final class SpeakerTableViewCell: NSTableCellView {
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var titleLabel: NSTextField!
}
