//
//  VideosViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/4/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit
import Haneke

@objc(OSSTVVideosViewController)
final class VideosViewController: CollectionViewController {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let predicate = NSPredicate(format: "event.summit.id == %@", summitID)
        
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        self.fetchedResultsController = NSFetchedResultsController(Video.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sortDescriptors,
                                                                   sectionNameKeyPath: nil,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController!.performFetch()
    }
    
    private func configure(cell cell: VideoCell, at indexPath: NSIndexPath) {
        
        let video = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Video.ManagedObject
        
        cell.label.text = video.event.name
        
        if let thumbnailURL = NSURL(youtubeThumbnail: video.youtube) {
            
            cell.imageView.hnk_setImageFromURL(thumbnailURL, placeholder: nil, format: nil, failure: nil, success: { (image) in
                
                cell.imageView.image = image
            })
        }
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

// MARK: - Supporting Types

@objc(OSSTVVideoCell)
final class VideoCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
}
