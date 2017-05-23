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
import Predicate
import XCDYouTubeKit

final class VideosViewController: NSViewController, NSFetchedResultsControllerDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate, SearchableController {
    
    typealias CollectionViewItem = ImageCollectionViewItem
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var collectionView: NSCollectionView!
    
    // MARK: - Properties
    
    var searchTerm = "" {
        
        didSet { configureView() }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<VideoManagedObject>!
    
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
        
        //let summitPredicate = NSPredicate(format: "event.summit.id == %@", summitID)
        let summitPredicate: Predicate = #keyPath(VideoManagedObject.event.summit.id) == SummitManager.shared.summit.value
        
        let searchPredicate: Predicate
        
        if searchTerm.isEmpty {
            
            searchPredicate = .value(true)
            
        } else {
            
            //searchPredicate = NSPredicate(format: "event.name CONTAINS[c] %@", searchTerm)
            searchPredicate = (#keyPath(VideoManagedObject.event.name)).compare(.contains, [.caseInsensitive], .value(.string(searchTerm)))
        }
        
        let predicate: Predicate = .compound(.and([searchPredicate, summitPredicate]))
        
        let sort = [NSSortDescriptor(key: "event.name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(Video.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sort,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        self.collectionView.reloadData()
    }
    
    private func configure(item: CollectionViewItem, at indexPath: IndexPath) {
        
        let video = fetchedResultsController.object(at: indexPath)
                
        item.textField!.stringValue = video.event.name
        
        item.imageURL = URL(youtubeThumbnail: video.youtube)
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
                        
            let video = fetchedResultsController.object(at: $0)
            
            AppDelegate.shared.mainWindowController.view(data: .video, identifier: video.id)
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
