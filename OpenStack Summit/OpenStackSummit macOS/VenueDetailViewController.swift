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
final class VenueDetailViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate, NSSharingServicePickerDelegate, NSSharingServiceDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var shareButton: NSButton!
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var addressLabel: NSTextField!
    
    @IBOutlet private(set) weak var venueImageViewContainer: NSView!
    
    @IBOutlet private(set) weak var venueImageView: NSImageView!
    
    @IBOutlet private(set) weak var venueImageActivityIndicator: NSProgressIndicator!
    
    @IBOutlet private(set) weak var descriptionView: NSView!
    
    @IBOutlet private(set) weak var descriptionLabel: NSTextField!
    
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
        
        shareButton.sendActionOn(.LeftMouseDown)
    }
    
    // MARK: - Actions
    
    @IBAction func share(sender: NSButton) {
        
        var items = [AnyObject]()
        
        items.append(venueCache.name)
        
        items.append(venueCache.address)
        
        if descriptionLabel.attributedStringValue.string.isEmpty == false {
            
            items.append(descriptionLabel.attributedStringValue)
        }
        
        if let _ = venueCache.backgroundImageURL,
            let venueImage = self.venueImageView.image {
            
            items.append(venueImage)
        }
        
        let sharingServicePicker = NSSharingServicePicker(items: items)
        
        sharingServicePicker.delegate = self
        
        sharingServicePicker.showRelativeToRect(sender.bounds,
                                                ofView: sender,
                                                preferredEdge: .MinY)
    }
    
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
        
        // set description
        let htmlString = venue.descriptionText
        
        if let data = htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            where attributedString.string.isEmpty == false {
            
            self.descriptionView.hidden = false
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: NSFont.systemFontOfSize(14), range: range)
            
            self.descriptionLabel.attributedStringValue = attributedString
            
        } else {
            
            self.descriptionView.hidden = true
            self.descriptionLabel.stringValue = ""
        }
        
        // TEMP
        imagesView.hidden = true
        mapImagesView.hidden = true
        
        //imagesView.hidden = venue.images.isEmpty
        //imagesCollectionView.reloadData()
        
        //mapImagesView.hidden = venue.maps.isEmpty
        //mapImagesCollectionView.reloadData()
        
        venueImageView.image = nil
        
        if let urlString = venue.backgroundImageURL,
            let imageURL = NSURL(string: urlString) {
            
            venueImageViewContainer.hidden = false
            
            venueImageActivityIndicator.hidden = false
            venueImageActivityIndicator.startAnimation(self)
            
            venueImageView.loadCached(imageURL) { [weak self] _ in
                
                if self?.venueImageView.image != nil {
                    
                    self?.venueImageActivityIndicator.stopAnimation(nil)
                    self?.venueImageActivityIndicator.hidden = true
                    
                } else {
                    
                    self?.venueImageViewContainer.hidden = true
                }
            }
            
        } else {
            
            venueImageViewContainer.hidden = true
            venueImageActivityIndicator.hidden = true
        }
    }
    
    private func configure(item item: VenueImageCollectionViewItem, at indexPath: NSIndexPath, collectionView: NSCollectionView) {
        
        let urlString: String
        
        switch collectionView {
        case imagesCollectionView: urlString = venueCache.images[indexPath.item]
        case mapImagesCollectionView: urlString = venueCache.maps[indexPath.item]
        default: fatalError()
        }
        
        item.imageView!.image = nil
        
        item.activityIndicator.hidden = false
        item.activityIndicator.startAnimation(nil)
        
        if let imageURL = NSURL(string: urlString) {
            
            item.imageView!.loadCached(imageURL) { _ in
                
                if let _ = item.imageView?.image {
                    
                    item.activityIndicator.hidden = true
                    item.activityIndicator.stopAnimation(nil)
                }
            }
        }
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case imagesCollectionView: return venueCache.images.count
        case mapImagesCollectionView: return venueCache.maps.count
        default: fatalError()
        }
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItemWithIdentifier("VenueImageCollectionViewItem", forIndexPath: indexPath) as! VenueImageCollectionViewItem
        
        configure(item: item, at: indexPath, collectionView: collectionView)
        
        return item
    }
    
    // MARK: - NSCollectionViewDelegate
    
    func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        
        defer { collectionView.deselectItemsAtIndexPaths(indexPaths) }
        
        let indexPath = indexPaths.first!
        
        let imageString: String
        
        switch collectionView {
        case imagesCollectionView: imageString = venueCache.images[indexPath.item]
        case mapImagesCollectionView: imageString = venueCache.maps[indexPath.item]
        default: fatalError()
        }
        
        if let url = NSURL(string: imageString) {
            
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
    
    // MARK: - NSSharingServicePickerDelegate
    
    func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [AnyObject], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
        
        var customItems = [NSSharingService]()
        
        if let airdrop = NSSharingService(named: NSSharingServiceNameSendViaAirDrop) {
            
            customItems.append(airdrop)
        }
        
        /*
        if let safariReadList = NSSharingService(named: NSSharingServiceNameAddToSafariReadingList) {
            
            customItems.append(safariReadList)
        }*/
        
        return customItems + proposedServices
    }
    
    func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, delegateForSharingService sharingService: NSSharingService) -> NSSharingServiceDelegate? {
        
        return self
    }
    
    // MARK: - NSSharingServiceDelegate
    
    func sharingService(sharingService: NSSharingService, willShareItems items: [AnyObject]) {
        
        sharingService.subject = nameLabel.stringValue
    }
    
    func sharingService(sharingService: NSSharingService, sourceFrameOnScreenForShareItem item: AnyObject) -> NSRect {
        
        if let image = item as? NSImage where image == self.venueImageView.image {
            
            let imageView = self.venueImageView
            
            var frame = imageView.convertRect(imageView.bounds, toView: nil)
            frame = imageView.window!.convertRectToScreen(frame)
            return frame
            
        } else {
            
            return .zero
        }
    }
    
    func sharingService(sharingService: NSSharingService, sourceWindowForShareItems items: [AnyObject], sharingContentScope: UnsafeMutablePointer<NSSharingContentScope>) -> NSWindow? {
        
        if self.view.window?.className == NSPopover.windowClassName {
            
            return presentingViewController?.view.window
            
        } else {
            
            return view.window
        }
    }
}

// MARK: - Supporting Types

final class VenueImageCollectionViewItem: ImageCollectionViewItem {
    
    @IBOutlet private(set) weak var activityIndicator: NSProgressIndicator!
}
