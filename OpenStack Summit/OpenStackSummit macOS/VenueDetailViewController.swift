//
//  VenueDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/21/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

@objc(OSSVenueDetailViewController)
final class VenueDetailViewController: NSViewController {
    
    // MARK: - IB Outlets
        
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var addressLabel: NSTextField!
    
    @IBOutlet private(set) weak var venueImageViewContainer: NSView!
    
    @IBOutlet private(set) weak var venueImageView: NSImageView!
    
    @IBOutlet private(set) weak var venueImageActivityIndicator: NSProgressIndicator!
    
    @IBOutlet private(set) weak var imagesView: NSView!
    
    @IBOutlet private(set) weak var imagesCollectionView: NSCollectionView!
    
    @IBOutlet private(set) weak var mapImagesView: NSView!
    
    @IBOutlet private(set) weak var mapImagesCollectionView: NSCollectionView!
    
    // MARK: - Properties
    
    var venue: Identifier = 0 {
        
        didSet { configureView() }
    }
    
    var entityController: EntityController<VenueListItem>!
    
    private var venueCache: VenueListItem!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Actions
    
    
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let _ = self.view
        
        assert(viewLoaded)
        
        entityController = EntityController(identifier: venue,
                                            entity: VenueManagedObject.self,
                                            context: Store.shared.managedObjectContext)
        
        entityController.event.updated = { [weak self] in self?.configureView($0) }
        
        entityController.event.deleted = { [weak self] _ in self?.dismissController(nil) }
        
        entityController.enabled = true
    }
    
    private func configureView(venue: VenueListItem) {
        
        venueCache = venue
        
        nameLabel.stringValue = venue.name
        
        addressLabel.stringValue = venue.address
        
        imagesView.hidden = venue.images.isEmpty
        imagesCollectionView.reloadData()
        
        mapImagesView.hidden = venue.maps.isEmpty
        mapImagesCollectionView.reloadData()
        
        venueImageView.image = nil
        
        if let urlString = venue.backgroundImageURL,
            let imageURL = NSURL(string: urlString) {
            
            venueImageViewContainer.hidden = false
            
            venueImageActivityIndicator.hidden = false
            venueImageActivityIndicator.startAnimation(self)
            
            venueImageView.loadCached(imageURL) { [weak self] _ in
                
                self?.venueImageActivityIndicator.stopAnimation(nil)
                self?.venueImageActivityIndicator.hidden = true
            }
            
        } else {
            
            venueImageViewContainer.hidden = true
            venueImageActivityIndicator.hidden = true
        }
    }
}
