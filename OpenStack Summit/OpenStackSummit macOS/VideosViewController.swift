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

final class VideosViewController: NSViewController, NSFetchedResultsControllerDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var collectionView: NSCollectionView!
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController!
    
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
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let predicate = NSPredicate(format: "event.summit.id == %@", summitID)
        
        let sort = [NSSortDescriptor(key: "event.name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(Video.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sort,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        self.collectionView.reloadData()
    }
    
    private func configure(item item: NSCollectionViewItem, at indexPath: NSIndexPath) {
        
        let video = fetchedResultsController.objectAtIndexPath(indexPath) as! VideoManagedObject
                
        item.textField!.stringValue = video.event.name
        
        item.imageView!.image = nil
        
        if let url = NSURL(youtubeThumbnail: video.youtube) {
            
            item.imageView!.loadCached(url)
        }
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItemWithIdentifier("VideoCollectionViewItem", forIndexPath: indexPath)
        
        configure(item: item, at: indexPath)
        
        return item
    }
    
    // MARK: - NSCollectionViewDelegate
    
    func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        
        defer { collectionView.deselectItemsAtIndexPaths(indexPaths) }
        
        indexPaths.forEach {
            
            let video = fetchedResultsController.objectAtIndexPath($0) as! VideoManagedObject
            
            let url = NSURL(string: "https://www.youtube.com/watch?v=" + video.youtube)!
            
            NSWorkspace.sharedWorkspace().openURL(url)
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
}
