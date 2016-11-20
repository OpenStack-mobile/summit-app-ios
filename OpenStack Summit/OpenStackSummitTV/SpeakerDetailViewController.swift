//
//  SpeakerDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/11/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit
import Haneke

@objc(OSSTVSpeakerDetailViewController)
final class SpeakerDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pictureImageView: UIImageView!
    
    // MARK: - Properties
    
    var speaker: Identifier!
    
    var entityController: EntityController<Speaker>!
    
    private var speakerCache: Speaker!
    
    private var data = [Detail]()
    
    private var eventsPredicate: NSPredicate!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 20
        
        pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
        pictureImageView.clipsToBounds = true
        
        configureController()
    }
    
    // MARK: - Private Methods
    
    private func configureController() {
        
        assert(speaker != nil, "No speaker set")
        
        self.entityController = EntityController(identifier: speaker, entity: SpeakerManagedObject.self, context: Store.shared.managedObjectContext)
        
        self.entityController.event.updated = updateUI
        
        eventsPredicate = NSPredicate(format: "ANY presentation.speakers.id == %@", NSNumber(longLong: Int64(self.speaker)))
        
        
    }
    
    private func updateUI(speaker: Speaker) {
        
        self.title = speaker.name
        
        self.speakerCache = speaker
        
        pictureImageView.hnk_setImageFromURL(NSURL(string: speaker.pictureURL)!, placeholder: UIImage(named: "generic-user-avatar"))
        
        data = []
        
        if speaker.twitter != nil {
            
            data.append(.twitter)
        }
        
        if speaker.irc != nil {
            
            data.append(.irc)
        }
        
        let eventCount = try! Store.shared.managedObjectContext.count(EventManagedObject.self)
        
        data.append(.sessions(eventCount))
        
        if speaker.biography != nil {
            
            data.append(.biography)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = self.data[indexPath.row]
        
        switch data {
            
        case .twitter:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SpeakerTwitterCell", forIndexPath: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel.text = speakerCache.twitter
            
            return cell
            
        case .irc:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SpeakerIRCCell", forIndexPath: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel.text = speakerCache.irc
            
            return cell
            
        case .biography:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SpeakerBiographyCell", forIndexPath: indexPath)
            
            if let data = speakerCache.biography?.dataUsingEncoding(NSUTF8StringEncoding),
                let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
                
                cell.textLabel!.text = attributedString.string
                
            } else {
                
                cell.textLabel!.text = "Invalid HTML."
            }
            
            return cell
            
        case let .sessions(eventCount):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SpeakerEventsCell", forIndexPath: indexPath) as! DetailImageTableViewCell
            
            cell.titleLabel.text = "\(eventCount) " + "\(eventCount == 1 ? "session" : "sessions")"
            
            return cell
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showSpeakerEvents":
            
            let eventsViewController = segue.destinationViewController as! EventsViewController
            
            eventsViewController.predicate = eventsPredicate
            
            eventsViewController.title = speakerCache.name
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}

// MARK: - Supporting Types

private extension SpeakerDetailViewController {
    
    enum Detail {
        
        case twitter
        case irc
        case sessions(Int)
        case biography
    }
}
