//
//  EventDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/5/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit
import Haneke
import XCDYouTubeKit

@objc(OSSTVEventDetailViewController)
final class EventDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    var event: Identifier!
    
    private var eventCache: Event!
    
    private var eventDetail: EventDetail!
    
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
        
        assert(event != nil, "No identifier set")
        
        guard let managedObject = try! EventManagedObject.find(event, context: Store.shared.managedObjectContext)
            else { fatalError("Invalid event \(event)") }
        
        self.eventCache = Event(managedObject: managedObject)
        self.eventDetail = EventDetail(managedObject: managedObject)
        
        self.data = [Detail]()
        
        data.append(.name)
        
        if eventDetail.track.isEmpty == false {
            
            data.append(.track)
        }
        
        if eventDetail.video != nil {
            
            data.append(.video)
        }
        
        data.append(.time)
        data.append(.location)
        data.append(.description)
        
        // reload table
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let detail = self.data[indexPath.row]
        
        switch detail {
            
        case .name:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventNameCell", forIndexPath: indexPath)
            
            cell.textLabel!.text = eventDetail.name
            
            return cell
            
        case .description:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventDescriptionCell", forIndexPath: indexPath)
            
            if let data = eventDetail.eventDescription.dataUsingEncoding(NSUTF8StringEncoding),
                let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
                
                cell.textLabel!.text = attributedString.string
                
            } else {
                
                cell.textLabel!.text = "No description."
            }
            
            return cell
            
        case .track:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventTrackCell", forIndexPath: indexPath)
            
            cell.textLabel!.text = eventDetail.track
            
            return cell
            
        case .time:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventTimeCell", forIndexPath: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel!.text = eventDetail.dateTime
            
            return cell
            
        case .video:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventVideoCell", forIndexPath: indexPath) as! VideoPlayerTableViewCell
            
            cell.playImageView.hidden = true
            cell.activityIndicator.hidden = false
            
            if let thumbnailURL = NSURL(youtubeThumbnail: eventDetail.video!.youtube) {
                
                cell.videoImageView.hnk_setImageFromURL(thumbnailURL, placeholder: nil, format: nil, failure: nil, success: { (image) in
                    
                    cell.videoImageView.image = image
                    cell.playImageView.hidden = false
                    cell.activityIndicator.stopAnimating()
                    cell.setNeedsDisplay()
                })
            }
            
            return cell
            
        case .location:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventLocationCell", forIndexPath: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel!.text = eventDetail.location
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let data = self.data[indexPath.row]
        
        switch data {
            
        case .video:
            
            self.playVideo(eventDetail.video!)
            
        default: break
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showTrackEvents":
            
            let predicate = NSPredicate(format: "track.id == %@", eventCache.track! as NSNumber)
            
            let eventsViewController = segue.destinationViewController as! EventsViewController
            
            eventsViewController.predicate = predicate
            
            eventsViewController.title = eventDetail.track
            
        case "eventShowVenue":
            
            guard let locationID = eventCache.location
                else { fatalError("Event has no location") }
            
            let location = try! Location.find(locationID, context: Store.shared.managedObjectContext)
            
            let venueDetailViewController = segue.destinationViewController as! VenueDetailViewController
            
            venueDetailViewController.location = location
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}

// MARK: - Supporting Types

private extension EventDetailViewController {
    
    enum Detail {
        
        case name
        case description
        case track
        case time
        case video
        case location
    }
}

final class VideoPlayerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
}
