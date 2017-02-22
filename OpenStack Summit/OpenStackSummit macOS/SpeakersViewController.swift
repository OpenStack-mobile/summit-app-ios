//
//  SpeakersViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

final class SpeakersViewController: NSViewController, NSFetchedResultsControllerDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate, SearchableController {
    
    typealias CollectionViewItem = ImageCollectionViewItem
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var collectionView: NSCollectionView!
    
    // MARK: - Properties
    
    var searchTerm = "" {
        
        didSet { configureView() }
    }
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    private var summitObserver: Int?
    
    private lazy var placeholderImage: NSImage = NSImage(named: "generic-user-avatar")!
    
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
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let summitPredicate = NSPredicate(format: "summits.id CONTAINS %@", summitID)
        
        let searchPredicate: NSPredicate
        
        if searchTerm.isEmpty {
            
            searchPredicate = NSPredicate(value: true)
            
        } else {
            
            searchPredicate = NSPredicate(format: "firstName CONTAINS[c] %@ OR lastName CONTAINS[c] %@", searchTerm, searchTerm)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, summitPredicate])
        
        self.fetchedResultsController = NSFetchedResultsController(Speaker.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: SpeakerManagedObject.sortDescriptors,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        self.collectionView.reloadData()
    }
    
    private func configure(item item: CollectionViewItem, at indexPath: NSIndexPath) {
        
        let managedObject = fetchedResultsController.objectAtIndexPath(indexPath) as! SpeakerManagedObject
        
        let speaker = Speaker(managedObject: managedObject)
        
        item.textField!.stringValue = speaker.name
        
        item.placeholderImage = self.placeholderImage
        
        item.imageURL = NSURL(string: speaker.pictureURL)
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItemWithIdentifier("PersonCollectionViewItem", forIndexPath: indexPath) as! CollectionViewItem
        
        configure(item: item, at: indexPath)
        
        return item
    }
    
    // MARK: - NSCollectionViewDelegate
    
    func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        
        defer { collectionView.deselectItemsAtIndexPaths(indexPaths) }
        
        let indexPath = indexPaths.first!
        
        let speaker = fetchedResultsController.objectAtIndexPath(indexPath) as! SpeakerManagedObject
        
        if let previousWindow = NSApp.windows.firstMatching({ ($0.windowController as? SpeakerWindowController)?.speaker == speaker.identifier }) {
            
            previousWindow.makeKeyAndOrderFront(nil)
            
        } else {
            
            self.performSegueWithIdentifier("showSpeaker", sender: nil)
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        //self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //self.tableView.endUpdates()
        
        self.collectionView.reloadData()
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showSpeaker":
            
            // get selected speaker
            
            let indexPath = collectionView.selectionIndexPaths.first!
            
            let speaker = fetchedResultsController.objectAtIndexPath(indexPath) as! SpeakerManagedObject
            
            // show window controller
            
            let windowController = segue.destinationController as! SpeakerWindowController
            
            windowController.speaker = speaker.identifier
            
        default: fatalError()
        }
    }
}
