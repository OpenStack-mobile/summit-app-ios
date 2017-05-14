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
import Predicate

@objc(OSSTVEventDetailViewController)
final class EventDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    var event: Identifier!
    
    private var eventCache: Event!
    
    private var eventDetail: EventDetail!
    
    private var data = [Detail]()
    
    private var videoImage: UIImage?
    
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
        self.videoImage = nil
        
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let detail = self.data[indexPath.row]
        
        switch detail {
            
        case .name:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventNameCell", for: indexPath)
            
            cell.textLabel!.text = eventDetail.name
            
            return cell
            
        case .description:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventDescriptionCell", for: indexPath)
            
            if let data = eventDetail.eventDescription.data(using: String.Encoding.utf8),
                let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                
                cell.textLabel!.text = attributedString.string
                
            } else {
                
                cell.textLabel!.text = "No description."
            }
            
            return cell
            
        case .track:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventTrackCell", for: indexPath)
            
            cell.textLabel!.text = eventDetail.track
            
            return cell
            
        case .time:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventTimeCell", for: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel!.text = eventDetail.dateTime
            
            return cell
            
        case .video:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventVideoCell", for: indexPath) as! VideoPlayerTableViewCell
            
            cell.playImageView.isHidden = true
            cell.activityIndicator.isHidden = false
            
            if let thumbnailURL = URL(youtubeThumbnail: eventDetail.video!.youtube) {
                
                cell.videoImageView.hnk_setImageFromURL(thumbnailURL, placeholder: nil, format: nil, failure: nil, success: { [weak self, cell] (image) in
                    
                    cell.videoImageView.image = image
                    cell.playImageView.isHidden = false
                    cell.activityIndicator.stopAnimating()
                    cell.setNeedsDisplay()
                    self?.videoImage = image
                })
            }
            
            return cell
            
        case .location:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventLocationCell", for: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel!.text = eventDetail.location
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = self.data[indexPath.row]
        
        switch data {
            
        case .video:
            
            self.play(video: eventDetail.video!, cachedImage: videoImage)
            
        default: break
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case "showTrackEvents":
            
            //let predicate = NSPredicate(format: "track.id == %@", eventCache.track! as NSNumber)
            let predicate: Predicate = #keyPath(EventManagedObject.track.id) == eventCache.track!
            
            let eventsViewController = segue.destination as! EventsViewController
            
            eventsViewController.predicate = predicate
            
            eventsViewController.title = eventDetail.track
            
        case "eventShowVenue":
            
            guard let locationID = eventCache.location
                else { fatalError("Event has no location") }
            
            let location = try! Location.find(locationID, context: Store.shared.managedObjectContext)
            
            let venueDetailViewController = segue.destination as! VenueDetailViewController
            
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
    
    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var playImageView: UIImageView!
    @IBOutlet private(set) weak var videoImageView: UIImageView!
}
