//
//  VenueDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

@objc(OSSTVVenueDetailViewController)
final class VenueDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    var location: Location!
    
    private lazy var venue: Venue = {
        
        switch self.location! {
            
        case let .venue(value): return value
            
        case let .room(room):
            
            guard let realmVenue = RealmVenue.find(room.venue, realm: Store.shared.realm)
                else { fatalError("Invalid venue \(room.venue)") }
            
            return Venue(realmEntity: realmVenue)
        }
    }()
    
    private var data = [Detail]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        switch location! {
            
        case let .venue(venue):
            
            configureView(for: venue)
            
        case let .room(room):
            
            configureView(for: self.venue, room: room)
        }
    }
    
    private func configureView(for venue: Venue, room: VenueRoom? = nil) {
        
        self.title = room == nil ? venue.name : venue.name + " - " + room!.name
        
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
}

// MARK: - Supporting Type

private extension VenueDetailViewController {
    
    enum Detail {
        
        case description
        case address
        case room
        case images
        case mapImages
    }
}
