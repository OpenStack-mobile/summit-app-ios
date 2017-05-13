//
//  VenueDetailInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class VenueDetailInterfaceController: WKInterfaceController {
    
    static let identifier = "VenueDetail"
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var addressLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var descriptionSeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var descriptionLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var capacityLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var capacitySeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var roomLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var roomSeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var mapView: WKInterfaceMap!
    
    @IBOutlet private(set) weak var imagesButton: WKInterfaceButton!
    
    @IBOutlet private(set) weak var imagesView: WKInterfaceImage!
    
    @IBOutlet private(set) weak var imagesActivityIndicator: WKInterfaceImage!
    
    @IBOutlet private(set) weak var mapImagesButton: WKInterfaceButton!
    
    @IBOutlet private(set) weak var mapImagesView: WKInterfaceImage!
    
    @IBOutlet private(set) weak var mapImagesActivityIndicator: WKInterfaceImage!
    
    // MARK: - Properties
    
    private(set) var location: Location!
    
    lazy var venue: Venue = {
        
        switch self.location! {
            
        case let .venue(value): return value
            
        case let .room(room):
            
            guard let value = Store.shared.cache?.locations.with(room.venue)?.rawValue as? Venue
                else { fatalError("Invalid venue \(room.venue)") }
            
            return value
        }
    }()
    
    // MARK: - Loading
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let location = (context as? Context<Location>)?.value
            else { fatalError("Invalid context") }
        
        self.location = location
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let type: AppActivitySummitDataType
        
        switch location! {
        case .venue: type = .venue
        case .room: type = .venueRoom
        }
        
        /// set user activity
        let activityUserInfo = [AppActivityUserInfo.type.rawValue: type.rawValue,
                                AppActivityUserInfo.identifier.rawValue: location.identifier] as [String : Any]
        
        updateUserActivity(AppActivity.view.rawValue, userInfo: activityUserInfo as [AnyHashable: Any], webpageURL: nil)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    @IBAction func showVenueImages(_ sender: AnyObject? = nil) {
        
        showImages(venue.images.sorted())
    }
    
    @IBAction func showMapImages(_ sender: AnyObject? = nil) {
        
        showImages(venue.maps.sorted())
    }
        
    // MARK: - Private Methods
    
    private func showImages(_ images: [Image]) {
        
        let names = [String](repeating: ImageInterfaceController.identifier, count: images.count)
        
        let contexts = images.map { Context($0) }
        
        presentController(withNames: names, contexts: contexts)
    }
    
    private func updateUI() {
        
        switch location! {
            
        case let .venue(venue):
            
            configureView(for: venue)
            
        case let .room(room):
            
            configureView(for: self.venue, room: room)
        }
    }
    
    private func configureView(for venue: Venue, room: VenueRoom? = nil) {
        
        let name: String = room == nil ? venue.name : venue.name + " - " + room!.name
        
        // set location name
        nameLabel.setText(name)
        
        // set venue description
        descriptionLabel.setText(venue.descriptionText)
        descriptionLabel.setHidden(venue.descriptionText == nil)
        descriptionSeparator.setHidden(venue.descriptionText == nil)
        
        if let descriptionText = venue.descriptionText,
            let data = descriptionText.data(using: String.Encoding.utf8),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            
            descriptionLabel.setText(attributedString.string)
            descriptionLabel.setHidden(false)
            descriptionSeparator.setHidden(false)
            
        } else {
            
            descriptionLabel.setHidden(true)
            descriptionSeparator.setHidden(true)
        }
        
        // address
        addressLabel.setText(venue.fullAddress)
        
        // set room capacity
        if let capacity = room?.capacity {
            
            capacityLabel.setText("\(capacity) capacity")
        }
        
        capacityLabel.setHidden(room?.capacity == nil)
        capacitySeparator.setHidden(room?.capacity == nil)
        
        // set room
        roomLabel.setText(room?.name)
        roomLabel.setHidden(room?.name == nil)
        roomSeparator.setHidden(room?.name == nil)
        
        // set images
        if let imageURL = venue.images.sorted().first?.url {
            
            // show activity indicator
            imagesActivityIndicator.setImageNamed("Activity")
            imagesActivityIndicator.startAnimatingWithImages(in: NSRange(location: 0, length: 30), duration: 1.0, repeatCount: 0)
            imagesActivityIndicator.setHidden(false)
            imagesView.setHidden(true)
            
            // load image
            imagesView.loadCached(imageURL) { [weak self] (response) in
                
                guard let controller = self else { return }
                
                // hide activity indicator
                controller.imagesActivityIndicator.setHidden(true)
                
                // hide image view if no image
                guard case .data = response else {
                    
                    controller.imagesView.setHidden(true)
                    return
                }
                
                controller.imagesView.setHidden(false)
            }
            
        } else {
            
            imagesButton.setHidden(true)
        }
        
        // set map images
        if let imageURL = venue.maps.sorted().first?.url {
            
            // show activity indicator
            mapImagesActivityIndicator.setImageNamed("Activity")
            mapImagesActivityIndicator.startAnimatingWithImages(in: NSRange(location: 0, length: 30), duration: 1.0, repeatCount: 0)
            mapImagesActivityIndicator.setHidden(false)
            mapImagesView.setHidden(true)
            
            // load image
            mapImagesView.loadCached(imageURL) { [weak self] (response) in
                
                guard let controller = self else { return }
                
                // hide activity indicator
                controller.mapImagesActivityIndicator.setHidden(true)
                
                // hide image view if no image
                guard case .data = response else {
                    
                    controller.mapImagesView.setHidden(true)
                    return
                }
                
                controller.mapImagesView.setHidden(false)
            }
            
        } else {
            
            mapImagesButton.setHidden(true)
        }
        
        // configure map
        if let coordinates = venue.location {
            
            let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
            
            mapView.setHidden(false)
            mapView.removeAllAnnotations()
            mapView.addAnnotation(center, with: .red)
            mapView.setRegion(region)
            
        } else {
            
            mapView.setHidden(true)
        }
    }
}
