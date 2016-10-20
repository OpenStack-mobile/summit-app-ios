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
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var moviePlayer: WKInterfaceMovie!
    
    @IBOutlet weak var dateLabel: WKInterfaceLabel!
    
    @IBOutlet weak var locationLabel: WKInterfaceLabel!
    
    @IBOutlet weak var locationSeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var locationButton: WKInterfaceButton!
    
    @IBOutlet weak var tagsLabel: WKInterfaceLabel!
    
    @IBOutlet weak var tagsGroup: WKInterfaceGroup!
    
    @IBOutlet weak var tagsSeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var speakersLabel: WKInterfaceLabel!
    
    @IBOutlet weak var speakersButton: WKInterfaceButton!
    
    @IBOutlet weak var speakersSeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var summitTypesLabel: WKInterfaceLabel!
    
    @IBOutlet weak var levelLabel: WKInterfaceLabel!
    
    @IBOutlet weak var levelGroup: WKInterfaceGroup!
    
    @IBOutlet weak var levelSeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    
    // MARK: - Properties
    
    private var event: Event!
    private var eventDetail: EventDetail!
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let eventID = (context as? Context<Identifier>)?.value,
            let realmEvent = RealmSummitEvent.find(eventID, realm: Store.shared.realm)
            else { fatalError("Invalid context") }
        
        self.event = Event(realmEntity: realmEvent)
        self.eventDetail = EventDetail(realmEntity: realmEvent)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /// set user activity
        let activityUserInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue,
                                AppActivityUserInfo.identifier.rawValue: eventDetail.id]
        
        updateUserActivity(AppActivity.view.rawValue, userInfo: activityUserInfo as [NSObject : AnyObject], webpageURL: eventDetail.webpageURL)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    @IBAction func showSpeakers(sender: AnyObject? = nil) {
                
        if eventDetail.speakers.count == 1 {
            
            let speaker = eventDetail.speakers[0]
            
            pushControllerWithName(SpeakerDetailInterfaceController.identifier, context: Context(speaker.identifier))
            
        } else {
            
            pushControllerWithName(SpeakersInterfaceController.identifier, context: Context(eventDetail.speakers.identifiers))
        }
    }
    
    @IBAction func showLocation(sender: AnyObject? = nil) {
        
        guard let realmSummit = Store.shared.realm.objects(RealmSummit).first,
            let locationID = event.location
            else { return }
        
        let summit = Summit(realmEntity: realmSummit)
        
        guard let location = summit.locations.with(locationID)
            else { fatalError("Invalid location \(locationID)") }
        
        self.pushControllerWithName(VenueDetailInterfaceController.identifier, context: Context(location))
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
        
        summitTypesLabel.setText(eventDetail.summitTypes)
        
        levelLabel.setText(eventDetail.level)
        levelGroup.setHidden(eventDetail.level.isEmpty)
        levelSeparator.setHidden(eventDetail.level.isEmpty)
        
        if let data = eventDetail.eventDescription.dataUsingEncoding(NSUTF8StringEncoding),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil)
            where eventDetail.eventDescription.isEmpty == false {
            
            descriptionLabel.setText(attributedString.string)
            
            descriptionLabel.setHidden(false)
            
        } else {
            
            descriptionLabel.setHidden(true)
        }
        
        if let video = eventDetail.video,
            let url = NSURL(string: "https://img.youtube.com/vi/" + video.youtube + "/default.jpg") {
            
            moviePlayer.setHidden(false)
            moviePlayer.loadCached(url)
            
        } else {
            
            moviePlayer.setHidden(true)
        }
    }
}
