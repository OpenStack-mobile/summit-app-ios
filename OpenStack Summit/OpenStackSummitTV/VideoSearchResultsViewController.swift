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
import Predicate
import func TVServices.TVTopShelfImageSize

@objc(OSSTVVideoSearchResultsViewController)
final class VideoSearchResultsViewController: CollectionViewController, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    var filterString = "" {
        
        didSet {
            
            // Return if the filter string hasn't changed.
            guard filterString != oldValue && isViewLoaded else { return }
            
            filterChanged()
        }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterChanged()
        
        // setup collection view
        let collectionViewLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewLayout.itemSize = TVTopShelfImageSize(shape: .HDTV, style: .sectioned)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resetScrollPosition()
    }
    
    // MARK: - Private Methods
    
    private func filterChanged() {
        
        let sort: [NSSortDescriptor]
        
        //let summitPredicate = NSPredicate(format: "event.summit.id == %@", summitID)
        var predicate: Predicate = #keyPath(VideoManagedObject.event.summit.id) == SummitManager.shared.summit.value
        
        if filterString.isEmpty {
            
           sort = [NSSortDescriptor(key: #keyPath(VideoManagedObject.event.start), ascending: true)]
            
        } else {
            
            sort = [NSSortDescriptor(key: #keyPath(VideoManagedObject.event.name), ascending: true)]
            
            //let filterPredicate = NSPredicate(format: "event.name CONTAINS[c] %@", filterString)
            let filter: Predicate = (#keyPath(VideoManagedObject.event.name)).compare(.contains, [.caseInsensitive], .value(.string(filterString)))
            
            predicate = predicate && filter
        }
        
        self.fetchedResultsController = NSFetchedResultsController(Video.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sort,
                                                                   sectionNameKeyPath: nil,
                                                                   context: Store.shared.managedObjectContext) as! NSFetchedResultsController<NSFetchRequestResult>
        
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 20
        
        try! self.fetchedResultsController.performFetch()
        
        self.resetScrollPosition()
        
        self.collectionView!.reloadData()
    }
    
    private func resetScrollPosition() {
        
        self.collectionView!.setContentOffset(.zero, animated: true)
    }
    
    private func configure(cell: VideoCell, at indexPath: IndexPath) {
        
        let video = self.fetchedResultsController.object(at: indexPath) as! Video.ManagedObject
        
        cell.label.text = video.event.name
        
        cell.imageView.image = nil
        
        if let thumbnailURL = URL(youtubeThumbnail: video.youtube) {
            
            cell.imageView.hnk_setImageFromURL(thumbnailURL, placeholder: nil, format: nil, failure: nil, success: { (image) in
                
                cell.imageView.image = image
            })
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // update filter string
        filterString = searchController.searchBar.text ?? ""
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let managedObject = self.fetchedResultsController.object(at: indexPath) as! Video.ManagedObject
        
        let video = Video(managedObject: managedObject)
        
        let cell = collectionView.cellForItem(at: indexPath) as! VideoCell
        
        self.play(video: video, cachedImage: cell.imageView?.image)
    }
}
