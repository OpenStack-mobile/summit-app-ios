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
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var addressLabel: WKInterfaceLabel!
    
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    
    @IBOutlet weak var capacityLabel: WKInterfaceLabel!
    
    @IBOutlet weak var capacitySeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var roomLabel: WKInterfaceLabel!
    
    @IBOutlet weak var roomSeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var mapView: WKInterfaceMap!
    
    @IBOutlet weak var imagesButton: WKInterfaceButton!
    
    @IBOutlet weak var imagesView: WKInterfaceImage!
    
    @IBOutlet weak var mapImagesButton: WKInterfaceButton!
    
    @IBOutlet weak var mapImagesView: WKInterfaceImage!
    
    // MARK: - Properties
    
    private(set) var location: Location!
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let location = (context as? Context<Location>)?.value
            else { fatalError("Invalid context") }
        
        self.location = location
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        switch location! {
            
        case let .venue(venue):
            
            configureView(for: venue)
            
        case let .room(room):
            
            guard let venue = Store.shared.cache?.locations.with(room.venue)?.rawValue as? Venue
                else { fatalError("Invalid venue \(room.venue)") }
            
            configureView(for: venue, room: room)
        }
    }
    
    private func configureView(for venue: Venue, room: VenueRoom? = nil) {
        
        let name: String = room == nil ? venue.name : venue.name + " - " + room!.name
        
        // set location name
        nameLabel.setText(name)
        
        // set venue description
        descriptionLabel.setText(venue.descriptionText)
        descriptionLabel.setHidden(venue.descriptionText == nil)
        
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
    }
}
