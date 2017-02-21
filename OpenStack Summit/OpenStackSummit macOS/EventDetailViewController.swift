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
    
    @IBOutlet private(set) weak var descriptionTextView: NSTextView!
    
    @IBOutlet private(set) weak var tableView: NSTableView!
    
    // MARK: - Properties
    
    var event: Identifier? {
        
        didSet { didSetEvent() }
    }
    
    var entityController: EntityController<EventDetail>?
    
    var eventDetail: EventDetail!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 1000
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
    
    // MARK: - Private Methods
    
    private func didSetEvent() {
        
        if let event = self.event {
            
            let entityController = EntityController<EventDetail>(identifier: event,
                                                                 entity: EventManagedObject.self,
                                                                 context: Store.shared.managedObjectContext)
            
            entityController.event.updated = { [weak self] in self?.configureView($0) }
            
            entityController.event.deleted = { [weak self] _ in self?.view.window?.close() }
            
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
        self.dateTimeLabel.stringValue = event.dateTime
        self.playVideoButton.hidden = event.video == nil
        
        let htmlString = event.eventDescription
        
        self.descriptionTextView.string = ""
        
        if let data = htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: NSFont.systemFontOfSize(14), range: range)
            
            self.descriptionTextView.textStorage!.appendAttributedString(attributedString)
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        return 0
    }
    
    // MARK: - NSTableViewDelegate
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView
        
        
        
        return cell
    }
    
    func tableView(tableView: NSTableView, isGroupRow row: Int) -> Bool {
        
        return false
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        return 10
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
        return true
    }
}

// MARK: - Supporting Types

private extension EventDetailViewController {
    
    enum Section: Int {
        
        static let count = 2
        
        case details
        case speakers
        //case feedback
    }
    
    enum Data {
        
        case date
        case location
        case description
        case level
        case speaker(EventDetail.SpeakerDetail)
    }
}

final class EventDetailHeader: NSTableCellView {
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var dateLabel: NSTextField!
    
    @IBOutlet private(set) weak var indicatorImageView: NSImageView!
}

final class EventDetailTableViewCell: NSTableCellView {
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var dateLabel: NSTextField!
    
    @IBOutlet private(set) weak var indicatorImageView: NSImageView!
}

