//
//  VideoSearchResultsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit
import Haneke

@objc(OSSTVVideoSearchResultsViewController)
final class VideoSearchResultsViewController: CollectionViewController, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    var filterString = "" {
        
        didSet {
            
            // Return if the filter string hasn't changed.
            guard filterString != oldValue && isViewLoaded() else { return }
            
            filterChanged()
        }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterChanged()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        resetScrollPosition()
    }
    
    // MARK: - Private Methods
    
    private func filterChanged() {
        
        let sort: [NSSortDescriptor]
        
        var predicates = [NSPredicate]()
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let summitPredicate = NSPredicate(format: "event.summit.id == %@", summitID)
        
        predicates.append(summitPredicate)
        
        if filterString.isEmpty {
            
           sort = [NSSortDescriptor(key: "event.start", ascending: true)]
            
        } else {
            
            sort = [NSSortDescriptor(key: "event.name", ascending: true)]
            
            let filterPredicate = NSPredicate(format: "event.name CONTAINS[c] %@", filterString)
            
            predicates.append(filterPredicate)
        }
        
        let predicate: NSPredicate?
        
        if predicates.count > 0 {
            
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
        } else {
            
            predicate = predicates.first
        }
        
        self.fetchedResultsController = NSFetchedResultsController(Video.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sort,
                                                                   sectionNameKeyPath: nil,
                                                                   context: Store.shared.managedObjectContext)
        
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 20
        
        try! self.fetchedResultsController.performFetch()
        
        self.resetScrollPosition()
        
        self.collectionView!.reloadData()
    }
    
    private func resetScrollPosition() {
        
        self.collectionView!.setContentOffset(.zero, animated: true)
    }
    
    private func configure(cell cell: VideoCell, at indexPath: NSIndexPath) {
        
        let video = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Video.ManagedObject
        
        cell.label.text = video.event.name
        
        cell.imageView.image = nil
        
        if let thumbnailURL = NSURL(youtubeThumbnail: video.youtube) {
            
            cell.imageView.hnk_setImageFromURL(thumbnailURL, placeholder: nil, format: nil, failure: nil, success: { (image) in
                
                cell.imageView.image = image
            })
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // update filter string
        filterString = searchController.searchBar.text ?? ""
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Video.ManagedObject
        
        let video = Video(managedObject: managedObject)
        
        self.play(video: video)
    }
}
