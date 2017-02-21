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
    
    @IBOutlet private(set) weak var headerView: NSView!
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var addressLabel: NSTextField!
    
    @IBOutlet private(set) weak var imagesCollectionView: NSCollectionView!
    
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
    
    // MARK: - Private Methods
    
    private func configureView() {
        
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
        
        
    }
}
