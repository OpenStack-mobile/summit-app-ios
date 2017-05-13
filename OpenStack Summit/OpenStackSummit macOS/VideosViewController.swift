//
//  VideosViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit
import XCDYouTubeKit

final class VideosViewController: NSViewController, NSFetchedResultsControllerDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate, SearchableController {
    
    typealias CollectionViewItem = ImageCollectionViewItem
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var collectionView: NSCollectionView!
    
    // MARK: - Properties
    
    var searchTerm = "" {
        
        didSet { configureView() }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
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
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let summitID = NSNumber(value: Int64(SummitManager.shared.summit.value))
        
        let summitPredicate = NSPredicate(format: "event.summit.id == %@", summitID)
        
        let searchPredicate: NSPredicate
        
        if searchTerm.isEmpty {
            
            searchPredicate = NSPredicate(value: true)
            
        } else {
            
            searchPredicate = NSPredicate(format: "event.name CONTAINS[c] %@", searchTerm)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, summitPredicate])
        
        let sort = [NSSortDescriptor(key: "event.name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(Video.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sort,
                                                                   context: Store.shared.managedObjectContext) as! NSFetchedResultsController<NSFetchRequestResult>
        
        try! self.fetchedResultsController.performFetch()
        
        self.collectionView.reloadData()
    }
    
    private func configure(item: CollectionViewItem, at indexPath: IndexPath) {
        
        let video = fetchedResultsController.object(at: indexPath) as! VideoManagedObject
                
        item.textField!.stringValue = video.event.name
        
        item.imageURL = URL(youtubeThumbnail: video.youtube) as! NSURL
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: "VideoCollectionViewItem", for: indexPath) as! CollectionViewItem
        
        configure(item: item, at: indexPath)
        
        return item
    }
    
    // MARK: - NSCollectionViewDelegate
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        defer { collectionView.deselectItems(at: indexPaths) }
        
        indexPaths.forEach {
                        
            let video = fetchedResultsController.object(at: $0) as! VideoManagedObject
            
            AppDelegate.shared.mainWindowController.view(.video, identifier: video.identifier)
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        //self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        //self.tableView.endUpdates()
        
        self.collectionView.reloadData()
    }
}
