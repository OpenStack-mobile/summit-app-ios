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
import EventKit

@objc(OSSEventDetailViewController)
final class EventDetailViewController: NSViewController, ContentController, MessageEnabledViewController, NSTableViewDataSource, NSTableViewDelegate, NSSharingServicePickerDelegate, NSSharingServiceDelegate, NSTextViewDelegate  {
    
    static let contentType: Any.Type = Event.self
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var trackLabel: NSTextField!
    
    @IBOutlet private(set) weak var dateTimeLabel: NSTextField!
    
    @IBOutlet private(set) weak var playVideoButton: NSButton!
    
    @IBOutlet private(set) weak var shareButton: NSButton!
    
    @IBOutlet private(set) weak var descriptionView: NSView!
    
    @IBOutlet private(set) weak var descriptionLabel: NSTextField!
    
    @IBOutlet private(set) weak var descriptionTextView: NSTextView!
    
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
    
    var contentIdentifier: Identifier = 0 {
        
        didSet { didSetEvent() }
    }
    
    var entityController: EntityController<EventDetail>!
    
    var eventDetail: EventDetail!
    
    private lazy var calendarEventStore: EKEventStore = EKEventStore()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.sendActionOn(.LeftMouseDown)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        userActivity?.becomeCurrent()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        userActivity?.resignCurrent()
    }
    
    override func updateUserActivityState(userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue,
                        AppActivityUserInfo.identifier.rawValue: self.contentIdentifier]
        
        userActivity.addUserInfoEntriesFromDictionary(userInfo as [NSObject : AnyObject])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Actions
    
    @IBAction func playVideo(sender: NSButton) {
        
        guard let video = eventDetail.video
            else { fatalError("Event has no video") }
        
        if let url = NSURL(string: "https://www.youtube.com/watch?v=" + video.youtube) {
            
            NSWorkspace.sharedWorkspace().openURL(url)
        }
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
        
        let event = self.contentIdentifier
        
        let entityController = EntityController<EventDetail>(identifier: event,
                                                             entity: EventManagedObject.self,
                                                             context: Store.shared.managedObjectContext)
        
        entityController.event.updated = { [weak self] in self?.configureView($0) }
        
        entityController.event.deleted = { [weak self] _ in self?.dismissController(nil) }
        
        entityController.enabled = true
        
        self.entityController = entityController
    }
    
    private func configureView(event: EventDetail) {
        
        self.eventDetail = event
        
        self.nameLabel.stringValue = event.name
        
        self.trackLabel.stringValue = event.track
        self.trackLabel.hidden = event.track.isEmpty
        
        self.dateTimeLabel.stringValue = event.dateTime
        
        self.playVideoButton.hidden = event.video == nil
        
        self.descriptionTextView.string = ""
        
        let htmlString = event.eventDescription
        
        if let data = htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            
            self.descriptionView.hidden = false
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: NSFont.systemFontOfSize(14), range: range)
            
            self.descriptionLabel.attributedStringValue = attributedString
            
            self.descriptionTextView.textStorage?.appendAttributedString(attributedString)
            
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
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
        userActivity.requiredUserInfoKeys = [AppActivityUserInfo.type.rawValue, AppActivityUserInfo.identifier.rawValue]
        userActivity.title = eventDetail.name
        userActivity.webpageURL = eventDetail.webpageURL
        userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue, AppActivityUserInfo.identifier.rawValue: self.contentIdentifier]
        
        
        self.userActivity = userActivity
    }
    
    func addToCalendar() {
        
        let event = eventDetail
        
        let status = EKEventStore.authorizationStatusForEntityType(.Event)
        
        switch status {
            
        case .Restricted, .Denied:
            
            break
            
        case .NotDetermined:
            
            calendarEventStore.requestAccessToEntityType(.Event) { [weak self] (granted, error) in
                
                // retry
                self?.addToCalendar()
            }
            
        case .Authorized:
            
            let calendarListTitle = "OpenStack Summit"
            
            // get calendar
            
            let calendar: EKCalendar
            
            if let existingCalendar = calendarEventStore.calendarsForEntityType(.Event).firstMatching({ $0.title == calendarListTitle }) {
                
                calendar = existingCalendar
                
            } else {
                
                calendar = EKCalendar(forEntityType: .Event, eventStore: calendarEventStore)
                
                calendar.title = calendarListTitle
                
                calendar.source = calendarEventStore.defaultCalendarForNewEvents.source
                
                do { try calendarEventStore.saveCalendar(calendar, commit: true) }
                    
                catch {
                    
                    showErrorMessage(error, fileName: #file, lineNumber: #line)
                    return
                }
            }
            
            // create event
            
            let calendarEvent = EKEvent(eventStore: calendarEventStore)
            
            calendarEvent.calendar = calendar
            calendarEvent.title = event.name
            calendarEvent.startDate = event.start.toFoundation()
            calendarEvent.endDate = event.end.toFoundation()
            calendarEvent.timeZone = NSTimeZone(name: event.timeZone)
            calendarEvent.URL = event.webpageURL
            calendarEvent.location = event.location
            
            if let data = event.eventDescription.dataUsingEncoding(NSUTF8StringEncoding),
                let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
                
                calendarEvent.notes = attributedString.string
            }
            
            do { try calendarEventStore.saveEvent(calendarEvent, span: .ThisEvent, commit: true) }
                
            catch { showErrorMessage(error) }
        }
    }
    
    // MARK: - NSTextFieldDelegate
    
    func textView(textView: NSTextView, clickedOnLink link: AnyObject, atIndex charIndex: Int) -> Bool {
        
        guard let url = link as? NSURL
            else { return false }
        
        return AppDelegate.shared.mainWindowController.openWebURL(url)
    }
    
    // MARK: - NSSharingServicePickerDelegate
    
    func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [AnyObject], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
        
        var customItems = [NSSharingService]()
        
        if let airdrop = NSSharingService(named: NSSharingServiceNameSendViaAirDrop) {
            
            customItems.append(airdrop)
        }
        
        if let safariReadList = NSSharingService(named: NSSharingServiceNameAddToSafariReadingList) {
            
            customItems.append(safariReadList)
        }
        
        if let url = eventDetail.webpageURL.absoluteString {
            
            let copyLink = NSSharingService(copyLink: url)
            
            customItems.append(copyLink)
        }
        
        let calendarIcon = NSWorkspace.sharedWorkspace().iconForFile("/Applications/Calendar.app")
        
        let addToCalendar = NSSharingService(title: "Save to Calendar",
                                             image: calendarIcon,
                                             alternateImage: nil,
                                             handler: self.addToCalendar)
        
        customItems.append(addToCalendar)
        
        return customItems + proposedServices
    }
    
    func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, delegateForSharingService sharingService: NSSharingService) -> NSSharingServiceDelegate? {
        
        return self
    }
    
    // MARK: - NSSharingServiceDelegate
    
    func sharingService(sharingService: NSSharingService, willShareItems items: [AnyObject]) {
        
        sharingService.subject = eventDetail.name
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showEventVenue":
            
            let venueDetailViewController = segue.destinationController as! VenueDetailViewController
            
            venueDetailViewController.venue = eventDetail.venue!.venue
            
        case "showEventSpeakers":
            
            let speakersViewController = segue.destinationController as! SpeakersTableViewController
            
            let eventID = NSNumber(longLong: Int64(eventDetail.identifier))
            
            speakersViewController.predicate = NSPredicate(format: "presentationModerator.event.id CONTAINS %@ OR presentationSpeaker.event.id CONTAINS %@", eventID, eventID)
            
            let speakerCount = speakersViewController.fetchedResultsController.fetchedObjects?.count ?? 0
            
            // set content size
            var contentSize = speakersViewController.view.bounds.size
            contentSize.height = speakersViewController.tableView.rowHeight * CGFloat(speakerCount)
            speakersViewController.view.setFrameSize(contentSize)
            
        default: fatalError()
        }
    }
}
