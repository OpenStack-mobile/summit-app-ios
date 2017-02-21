//
//  EventDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

@objc(OSSEventDetailViewController)
final class EventDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSSharingServicePickerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var trackLabel: NSTextField!
    
    @IBOutlet private(set) weak var dateTimeLabel: NSTextField!
    
    @IBOutlet private(set) weak var playVideoButton: NSButton!
    
    @IBOutlet private(set) weak var shareButton: NSButton!
    
    @IBOutlet private(set) weak var descriptionView: NSView!
    
    @IBOutlet private(set) weak var descriptionLabel: NSTextField!
    
    @IBOutlet private(set) weak var locationView: NSView!
    
    @IBOutlet private(set) weak var locationButton: NSButton!
    
    @IBOutlet private(set) weak var levelView: NSView!
    
    @IBOutlet private(set) weak var levelButton: NSButton!
    
    @IBOutlet private(set) weak var tagView: NSView!
    
    @IBOutlet private(set) weak var tagLabel: NSTextField!
    
    @IBOutlet private(set) weak var speakersView: NSView!
    
    @IBOutlet private(set) weak var speakersButton: NSButton!
    
    @IBOutlet private(set) weak var reviewsView: NSView!
    
    @IBOutlet private(set) weak var reviewsButton: NSButton!
    
    // MARK: - Properties
    
    var event: Identifier? {
        
        didSet { didSetEvent() }
    }
    
    var entityController: EntityController<EventDetail>!
    
    var eventDetail: EventDetail!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.rowHeight = 1000
    }
    
    // MARK: - Actions
    
    @IBAction func playVideo(sender: NSButton) {
        
        
    }
    
    @IBAction func share(sender: NSButton) {
        
        let message = "Check out this #OpenStack session I’m attending at the #OpenStackSummit!"
        
        let items = [message, eventDetail.webpageURL]
        
        let sharingServicePicker = NSSharingServicePicker(items: items)
        
        sharingServicePicker.delegate = self
        
        sharingServicePicker.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MinY)
    }
    
    @IBAction func showLevel(sender: NSButton) {
        
        
    }
    
    // MARK: - Private Methods
    
    private func didSetEvent() {
        
        if let event = self.event {
            
            let entityController = EntityController<EventDetail>(identifier: event,
                                                                 entity: EventManagedObject.self,
                                                                 context: Store.shared.managedObjectContext)
            
            entityController.event.updated = { [weak self] in self?.configureView($0) }
            
            entityController.event.deleted = { [weak self] _ in self?.dismissController(nil) }
            
            entityController.enabled = true
            
            self.entityController = entityController
            
        } else {
            
            entityController = nil
        }
    }
    
    private func configureView(event: EventDetail) {
        
        self.eventDetail = event
        
        self.nameLabel.stringValue = event.name
        
        self.trackLabel.stringValue = event.track
        self.trackLabel.hidden = event.track.isEmpty
        
        self.dateTimeLabel.stringValue = event.dateTime
        
        self.playVideoButton.hidden = event.video == nil
        
        let htmlString = event.eventDescription
        
        if let data = htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            
            self.descriptionView.hidden = false
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: NSFont.systemFontOfSize(14), range: range)
            
            self.descriptionLabel.attributedStringValue = attributedString
            
        } else {
            
            self.descriptionView.hidden = true
            self.descriptionLabel.stringValue = ""
        }
        
        self.locationView.hidden = event.location.isEmpty
        self.locationButton.title = event.location
        
        self.levelView.hidden = event.level.isEmpty
        self.levelButton.title = event.level
        
        self.tagView.hidden = event.tags.isEmpty
        self.tagLabel.stringValue = event.tags
        
        self.speakersView.hidden = event.speakers.isEmpty
        self.speakersButton.title = "\(event.speakers.count) speakers"
        
        self.reviewsView.hidden = true
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showEventVenue":
            
            let venueDetailViewController = segue.destinationController as! VenueDetailViewController
            
            venueDetailViewController.venue = eventDetail.venue!.venue
            
        case "showEventSpeakers":
            
            break
            
        default: fatalError()
        }
    }
}
