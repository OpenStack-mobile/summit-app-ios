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
        
        shareButton.sendAction(on: .leftMouseDown)
    }
    
    // MARK: - Actions
    
    @IBAction func share(_ sender: NSButton) {
        
        var items = [AnyObject]()
        
        items.append(venueCache.name as AnyObject)
        
        items.append(venueCache.address as AnyObject)
        
        if descriptionLabel.attributedStringValue.string.isEmpty == false {
            
            items.append(descriptionLabel.attributedStringValue)
        }
        
        if let _ = venueCache.backgroundImage,
            let venueImage = self.venueImageView.image {
            
            items.append(venueImage)
        }
        
        let sharingServicePicker = NSSharingServicePicker(items: items)
        
        sharingServicePicker.delegate = self
        
        sharingServicePicker.show(relativeTo: sender.bounds,
                                                of: sender,
                                                preferredEdge: .minY)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let _ = self.view
        
        assert(isViewLoaded)
        
        entityController = EntityController(identifier: venue,
                                            entity: VenueManagedObject.self,
                                            context: Store.shared.managedObjectContext)
        
        entityController.event.updated = { [weak self] in self?.configureView($0) }
        
        entityController.event.deleted = { [weak self] _ in self?.dismiss(nil) }
        
        entityController.enabled = true
    }
    
    private func configureView(_ venue: VenueListItem) {
        
        venueCache = venue
        
        nameLabel.stringValue = venue.name
        addressLabel.stringValue = venue.address
        
        // set description
        let htmlString = venue.descriptionText
        
        if let data = htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil),
            attributedString.string.isEmpty == false {
            
            self.descriptionView.isHidden = false
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: NSFont.systemFont(ofSize: 14), range: range)
            
            self.descriptionLabel.attributedStringValue = attributedString
            
        } else {
            
            self.descriptionView.isHidden = true
            self.descriptionLabel.stringValue = ""
        }
        
        // TEMP
        imagesView.isHidden = true
        mapImagesView.isHidden = true
        
        //imagesView.hidden = venue.images.isEmpty
        //imagesCollectionView.reloadData()
        
        //mapImagesView.hidden = venue.maps.isEmpty
        //mapImagesCollectionView.reloadData()
        
        venueImageView.image = nil
        
        if let imageURL = venue.backgroundImage {
            
            venueImageViewContainer.isHidden = false
            
            venueImageActivityIndicator.isHidden = false
            venueImageActivityIndicator.startAnimation(self)
            
            venueImageView.loadCached(imageURL) { [weak self] _ in
                
                if self?.venueImageView.image != nil {
                    
                    self?.venueImageActivityIndicator.stopAnimation(nil)
                    self?.venueImageActivityIndicator.isHidden = true
                    
                } else {
                    
                    self?.venueImageViewContainer.isHidden = true
                }
            }
            
        } else {
            
            venueImageViewContainer.isHidden = true
            venueImageActivityIndicator.isHidden = true
        }
    }
    
    private func configure(item: VenueImageCollectionViewItem, at indexPath: IndexPath, collectionView: NSCollectionView) {
        
        let url: URL
        
        switch collectionView {
        case imagesCollectionView: url = venueCache.images[indexPath.item]
        case mapImagesCollectionView: url = venueCache.maps[indexPath.item]
        default: fatalError("Invalid collection view \(collectionView)")
        }
        
        item.imageView!.image = nil
        
        item.activityIndicator.isHidden = false
        item.activityIndicator.startAnimation(nil)
        
        item.imageView!.loadCached(url) { _ in
            
            if let _ = item.imageView?.image {
                
                item.activityIndicator.isHidden = true
                item.activityIndicator.stopAnimation(nil)
            }
        }
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case imagesCollectionView: return venueCache.images.count
        case mapImagesCollectionView: return venueCache.maps.count
        default: fatalError("Invalid collection view \(collectionView)")
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: "VenueImageCollectionViewItem", for: indexPath) as! VenueImageCollectionViewItem
        
        configure(item: item, at: indexPath, collectionView: collectionView)
        
        return item
    }
    
    // MARK: - NSCollectionViewDelegate
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        defer { collectionView.deselectItems(at: indexPaths) }
        
        let indexPath = indexPaths.first!
        
        let imageURL: URL
        
        switch collectionView {
        case imagesCollectionView: imageURL = venueCache.images[indexPath.item]
        case mapImagesCollectionView: imageURL = venueCache.maps[indexPath.item]
        default: fatalError()
        }
        
        NSWorkspace.shared().open(imageURL)
    }
    
    // MARK: - NSSharingServicePickerDelegate
    
    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
        
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
    
    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> NSSharingServiceDelegate? {
        
        return self
    }
    
    // MARK: - NSSharingServiceDelegate
    
    func sharingService(_ sharingService: NSSharingService, willShareItems items: [Any]) {
        
        sharingService.subject = nameLabel.stringValue
    }
    
    func sharingService(_ sharingService: NSSharingService, sourceFrameOnScreenForShareItem item: Any) -> NSRect {
        
        if let image = item as? NSImage, image == self.venueImageView.image {
            
            let imageView = self.venueImageView
            
            var frame = imageView?.convert((imageView?.bounds)!, to: nil)
            frame = imageView?.window!.convertToScreen(frame!)
            return frame!
            
        } else {
            
            return .zero
        }
    }
    
    func sharingService(_ sharingService: NSSharingService, sourceWindowForShareItems items: [Any], sharingContentScope: UnsafeMutablePointer<NSSharingContentScope>) -> NSWindow? {
        
        if self.view.window?.className == NSPopover.windowClassName {
            
            return presenting?.view.window
            
        } else {
            
            return view.window
        }
    }
}

// MARK: - Supporting Types

final class VenueImageCollectionViewItem: ImageCollectionViewItem {
    
    @IBOutlet private(set) weak var activityIndicator: NSProgressIndicator!
}
