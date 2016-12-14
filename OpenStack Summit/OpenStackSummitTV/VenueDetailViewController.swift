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
    
    var canShowMap = true
    
    var location: Location!
    
    private lazy var venue: Venue = {
        
        switch self.location! {
            
        case let .venue(value): return value
            
        case let .room(room):
            
            guard let venue = try! Venue.find(room.venue, context: Store.shared.managedObjectContext)
                else { fatalError("Invalid venue \(room.venue)") }
            
            return venue
        }
    }()
    
    private var data = [Detail]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 90
        
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
        
        data = []
        
        if room != nil {
            
            data.append(.room)
        }
        
        if venue.fullAddress.isEmpty == false {
            
            data.append(.address)
        }
        
        if venue.images.isEmpty == false {
            
            data.append(.images)
        }
        
        if venue.maps.isEmpty == false {
            
            data.append(.mapImages)
        }
        
        if venue.descriptionText != nil {
            
            data.append(.description)
        }
        
        // reload table view
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = self.data[indexPath.row]
        
        switch data {
            
        case .room:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("VenueTextCell", forIndexPath: indexPath)
            
            let room = location.rawValue as! VenueRoom
            
            cell.textLabel!.text = room.name
            
            cell.accessoryType = .None
            
            return cell
            
        case .address:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("VenueLocationCell", forIndexPath: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel.text = venue.fullAddress
            
            return cell
            
        case .images:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("VenueTextCell", forIndexPath: indexPath)
            
            cell.textLabel!.text = venue.images.count == 1 ? "View Image" : "\(venue.images.count) images"
            
            cell.accessoryType = .DisclosureIndicator
            
            return cell
            
        case .mapImages:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("VenueTextCell", forIndexPath: indexPath)
            
            cell.textLabel!.text = venue.maps.count == 1 ? "View Map Image" : "\(venue.images.count) map images"
            
            cell.accessoryType = canShowMap ? .DisclosureIndicator : .None
            
            return cell
            
        case .description:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("VenueTextCell", forIndexPath: indexPath)
            
            let text: String
            
            if let descriptionText = venue.descriptionText,
                let data = descriptionText.dataUsingEncoding(NSUTF8StringEncoding),
                let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
                
                text = attributedString.string
                
            } else {
                
                text = ""
            }
            
            cell.textLabel!.text = text
            
            cell.accessoryType = .None
            
            return cell
        }
    }
    
    // MARK: - Segue
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        switch identifier {
            
        case "venueDetailShowMap": return canShowMap
            
        default: return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "venueDetailShowMap":
            
            let venueMapViewController = segue.destinationViewController as! VenueMapViewController
            
            venueMapViewController.selectedVenue = venue.identifier
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}

// MARK: - Supporting Type

private extension VenueDetailViewController {
    
    enum Detail {
        
        case room
        case address
        case images
        case mapImages
        case description
    }
}
