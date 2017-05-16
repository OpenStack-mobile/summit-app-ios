//
//  EventDetailInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class EventDetailInterfaceController: WKInterfaceController {
    
    static let identifier = "EventDetail"
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var moviePlayer: WKInterfaceMovie!
    
    @IBOutlet private(set) weak var dateLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var locationLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var locationSeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var locationButton: WKInterfaceButton!
    
    @IBOutlet private(set) weak var tagsLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var tagsGroup: WKInterfaceGroup!
    
    @IBOutlet private(set) weak var tagsSeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var speakersLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var speakersButton: WKInterfaceButton!
    
    @IBOutlet private(set) weak var speakersSeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var levelLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var levelGroup: WKInterfaceGroup!
    
    @IBOutlet private(set) weak var levelSeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var descriptionLabel: WKInterfaceLabel!
    
    // MARK: - Properties
    
    private var event: Event!
    
    private var eventDetail: EventDetail!
    
    // MARK: - Loading
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let event = (context as? Context<Event>)?.value
            else { fatalError("Invalid context") }
        
        self.event = event
        self.eventDetail = EventDetail(event: event, summit: Store.shared.cache!)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /// set user activity
        let activityUserInfo: [String: Any] = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue,
                                AppActivityUserInfo.identifier.rawValue: eventDetail.identifier]
        
        updateUserActivity(AppActivity.view.rawValue, userInfo: activityUserInfo, webpageURL: eventDetail.webpageURL)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    @IBAction func showSpeakers(_ sender: AnyObject? = nil) {
        
        if eventDetail.speakers.count == 1 {
            
            let speaker = eventDetail.speakers[0]
            
            pushController(withName: SpeakerDetailInterfaceController.identifier, context: Context(speaker))
            
        } else {
            
            pushController(withName: SpeakersInterfaceController.identifier, context: Context(eventDetail.speakers))
        }
    }
    
    @IBAction func showLocation(_ sender: AnyObject? = nil) {
        
        guard let summit = Store.shared.cache,
            let locationID = event.location
            else { return }
        
        guard let location = summit.locations.with(locationID)
            else { fatalError("Invalid location \(locationID)") }
        
        self.pushController(withName: VenueDetailInterfaceController.identifier, context: Context(location))
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        nameLabel.setText(eventDetail.name)
        dateLabel.setText(eventDetail.dateTime)
        
        locationLabel.setText(eventDetail.location)
        locationButton.setHidden(eventDetail.location.isEmpty)
        locationSeparator.setHidden(eventDetail.location.isEmpty)
        
        tagsLabel.setText(eventDetail.tags)
        tagsGroup.setHidden(eventDetail.tags.isEmpty)
        tagsSeparator.setHidden(eventDetail.tags.isEmpty)
        
        if eventDetail.speakers.count == 1 {
            
            speakersLabel.setText(eventDetail.speakers[0].name)
            
        } else {
            
            speakersLabel.setText("\(eventDetail.speakers.count) speakers")
        }
        
        speakersButton.setHidden(eventDetail.speakers.isEmpty)
        speakersSeparator.setHidden(eventDetail.speakers.isEmpty)
        
        levelLabel.setText(eventDetail.level)
        levelGroup.setHidden(eventDetail.level.isEmpty)
        levelSeparator.setHidden(eventDetail.level.isEmpty)
        
        if let descriptionText = eventDetail.descriptionText,
            let data = descriptionText.data(using: String.Encoding.utf8),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            
            descriptionLabel.setText(attributedString.string)
            
            descriptionLabel.setHidden(false)
            
        } else {
            
            descriptionLabel.setHidden(true)
        }
        
        if let video = eventDetail.video,
            let url = URL(string: "https://img.youtube.com/vi/" + video.youtube + "/default.jpg") {
            
            moviePlayer.setHidden(false)
            moviePlayer.loadCached(url)
            
        } else {
            
            moviePlayer.setHidden(true)
        }
    }
}
