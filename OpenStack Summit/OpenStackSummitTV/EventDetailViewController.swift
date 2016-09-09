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
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        assert(event != nil, "No identifier set")
        
        guard let realmEvent = RealmSummitEvent.find(event, realm: Store.shared.realm)
            else { fatalError("Invalid event \(event)") }
        
        self.eventCache = Event(realmEntity: realmEvent)
        self.eventDetail = EventDetail(realmEntity: realmEvent)
        
        self.data = [Detail]()
        
        data.append(.name(eventDetail.name))
        
        if eventDetail.track.isEmpty == false {
            
            data.append(.track(eventDetail.track))
        }
        
        data.append(.time(eventDetail.dateTime))
        
        if let video = eventDetail.video,
            let thumbnailURL = NSURL(youtubeThumbnail: video.youtube) {
            
            data.append(.video(thumbnailURL))
        }
        
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
            
        case let .name(name):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventNameCell", forIndexPath: indexPath)
            
            cell.textLabel!.text = name
            
            return cell
            
        case let .track(name):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventTrackCell", forIndexPath: indexPath)
            
            cell.textLabel!.text = name
            
            return cell
            
        case let .time(text):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventTimeCell", forIndexPath: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel!.text = text
            
            return cell
            
        case let .video(imageURL):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventVideoCell", forIndexPath: indexPath) as! VideoPlayerTableViewCell
            
            cell.videoImageView.hidden = true
            cell.playImageView.hidden = true
            cell.activityIndicator.hidden = false
            
            cell.videoImageView.hnk_setImageFromURL(imageURL, placeholder: nil, format: nil, failure: nil, success: { _ in
                
                cell.videoImageView.hidden = false
                cell.playImageView.hidden = false
                cell.activityIndicator.stopAnimating()
            })
            cell.videoImageView.hnk_setImageFromURL(imageURL)
            
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
            
            let predicate = NSPredicate(format: "presentation.track.id == %@", eventCache.presentation!.track! as NSNumber)
            
            let eventsViewController = segue.destinationViewController as! EventsViewController
            
            eventsViewController.predicate = predicate
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}

// MARK: - Supporting Types

private extension EventDetailViewController {
    
    enum Detail {
        
        case name(String)
        case track(String)
        case time(String)
        case video(NSURL)
        
    }
}

final class VideoPlayerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
}
