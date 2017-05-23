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
import Predicate

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
        
        shareButton.sendAction(on: .leftMouseDown)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        userActivity?.becomeCurrent()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        userActivity?.resignCurrent()
    }
    
    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue,
                        AppActivityUserInfo.identifier.rawValue: self.contentIdentifier] as [String : Any]
        
        userActivity.addUserInfoEntries(from: userInfo as [AnyHashable: Any])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Actions
    
    @IBAction func playVideo(_ sender: NSButton) {
        
        guard let video = eventDetail.video
            else { fatalError("Event has no video") }
        
        if let url = URL(string: "https://www.youtube.com/watch?v=" + video.youtube) {
            
            NSWorkspace.shared().open(url)
        }
    }
    
    @IBAction func share(_ sender: NSButton) {
        
        let message = "Check out this #OpenStack session I’m attending at the #OpenStackSummit!"
        
        let items = [message, eventDetail.webpage] as [Any]
        
        let sharingServicePicker = NSSharingServicePicker(items: items)
        
        sharingServicePicker.delegate = self
        
        sharingServicePicker.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
    }
    
    @IBAction func showLevel(_ sender: NSButton) {
        
        
    }
    
    // MARK: - Private Methods
    
    private func didSetEvent() {
        
        let event = self.contentIdentifier
        
        let entityController = EntityController<EventDetail>(identifier: event,
                                                             entity: EventManagedObject.self,
                                                             context: Store.shared.managedObjectContext)
        
        entityController.event.updated = { [weak self] in self?.configureView($0) }
        
        entityController.event.deleted = { [weak self] _ in self?.dismiss(nil) }
        
        entityController.enabled = true
        
        self.entityController = entityController
    }
    
    private func configureView(_ event: EventDetail) {
        
        self.eventDetail = event
        
        self.nameLabel.stringValue = event.name
        
        self.trackLabel.stringValue = event.track
        self.trackLabel.isHidden = event.track.isEmpty
        
        self.dateTimeLabel.stringValue = event.dateTime
        
        self.playVideoButton.isHidden = event.video == nil
        
        self.descriptionTextView.string = ""
        
        let htmlString = event.eventDescription
        
        if let data = htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            
            self.descriptionView.isHidden = false
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: NSFont.systemFont(ofSize: 14), range: range)
            
            self.descriptionLabel.attributedStringValue = attributedString
            
            self.descriptionTextView.textStorage?.append(attributedString)
            
        } else {
            
            self.descriptionView.isHidden = true
            self.descriptionLabel.stringValue = ""
        }
        
        self.locationView.isHidden = event.location.isEmpty
        self.locationButton.title = event.location
        
        self.levelView.isHidden = event.level.isEmpty
        self.levelButton.title = event.level
        
        self.tagView.isHidden = event.tags.isEmpty
        self.tagLabel.stringValue = event.tags
        
        self.speakersView.isHidden = event.speakers.isEmpty
        self.speakersButton.title = "\(event.speakers.count) speakers"
        
        self.reviewsView.isHidden = true
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
        userActivity.requiredUserInfoKeys = [AppActivityUserInfo.type.rawValue, AppActivityUserInfo.identifier.rawValue]
        userActivity.title = eventDetail.name
        userActivity.webpageURL = eventDetail.webpage
        userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue, AppActivityUserInfo.identifier.rawValue: self.contentIdentifier]
        
        
        self.userActivity = userActivity
    }
    
    func addToCalendar() {
        
        guard let event = eventDetail
            else { fatalError("No Event") }
        
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
            
        case .restricted, .denied:
            
            break
            
        case .notDetermined:
            
            calendarEventStore.requestAccess(to: .event) { [weak self] (granted, error) in
                
                // retry
                self?.addToCalendar()
            }
            
        case .authorized:
            
            let calendarListTitle = "OpenStack Summit"
            
            // get calendar
            
            let calendar: EKCalendar
            
            if let existingCalendar = calendarEventStore.calendars(for: .event).first(where: { $0.title == calendarListTitle }) {
                
                calendar = existingCalendar
                
            } else {
                
                calendar = EKCalendar(for: .event, eventStore: calendarEventStore)
                
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
            calendarEvent.startDate = event.start
            calendarEvent.endDate = event.end
            calendarEvent.timeZone = TimeZone(identifier: event.timeZone)
            calendarEvent.url = event.webpage
            calendarEvent.location = event.location
            
            if let data = event.eventDescription.data(using: String.Encoding.utf8),
                let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                
                calendarEvent.notes = attributedString.string
            }
            
            do { try calendarEventStore.save(calendarEvent, span: .thisEvent, commit: true) }
                
            catch { showErrorMessage(error) }
        }
    }
    
    // MARK: - NSTextFieldDelegate
    
    func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
        
        guard let url = link as? URL
            else { return false }
        
        return AppDelegate.shared.mainWindowController.openWeb(url: url)
    }
    
    // MARK: - NSSharingServicePickerDelegate
    
    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
        
        var customItems = [NSSharingService]()
        
        if let airdrop = NSSharingService(named: NSSharingServiceNameSendViaAirDrop) {
            
            customItems.append(airdrop)
        }
        
        if let safariReadList = NSSharingService(named: NSSharingServiceNameAddToSafariReadingList) {
            
            customItems.append(safariReadList)
        }
        
        do {
            
            let url = eventDetail.webpage.absoluteString
            
            let copyLink = NSSharingService(copyLink: url)
            
            customItems.append(copyLink)
        }
        
        let calendarIcon = NSWorkspace.shared().icon(forFile: "/Applications/Calendar.app")
        
        let addToCalendar = NSSharingService(title: "Save to Calendar",
                                             image: calendarIcon,
                                             alternateImage: nil,
                                             handler: self.addToCalendar)
        
        customItems.append(addToCalendar)
        
        return customItems + proposedServices
    }
    
    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> NSSharingServiceDelegate? {
        
        return self
    }
    
    // MARK: - NSSharingServiceDelegate
    
    func sharingService(_ sharingService: NSSharingService, willShareItems items: [Any]) {
        
        sharingService.subject = eventDetail.name
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case "showEventVenue":
            
            let venueDetailViewController = segue.destinationController as! VenueDetailViewController
            
            venueDetailViewController.venue = eventDetail.venue!.venue
            
        case "showEventSpeakers":
            
            let speakersViewController = segue.destinationController as! SpeakersTableViewController
            
            let eventID = Expression.value(.int64(eventDetail.identifier))
            
            //speakersViewController.predicate = NSPredicate(format: "presentationModerator.event.id CONTAINS %@ OR presentationSpeaker.event.id CONTAINS %@", eventID, eventID)
            speakersViewController.predicate = (#keyPath(SpeakerManagedObject.presentationModerator.event.id)).compare(.contains, eventID)
                || (#keyPath(SpeakerManagedObject.presentationSpeaker.event.id)).compare(.contains, eventID)
            
            let speakerCount = speakersViewController.fetchedResultsController.fetchedObjects?.count ?? 0
            
            // set content size
            var contentSize = speakersViewController.view.bounds.size
            contentSize.height = speakersViewController.tableView.rowHeight * CGFloat(speakerCount)
            speakersViewController.view.setFrameSize(contentSize)
            
        default: fatalError()
        }
    }
}
