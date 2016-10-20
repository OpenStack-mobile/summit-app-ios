//
//  SpeakerDetailInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class SpeakerDetailInterfaceController: WKInterfaceController {
    
    static let identifier = "SpeakerDetail"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    
    @IBOutlet weak var imageView: WKInterfaceImage!
    
    @IBOutlet weak var twitterLabel: WKInterfaceLabel!
    
    @IBOutlet weak var twitterGroup: WKInterfaceGroup!
    
    @IBOutlet weak var twitterSeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var ircLabel: WKInterfaceLabel!
    
    @IBOutlet weak var ircGroup: WKInterfaceGroup!
    
    @IBOutlet weak var ircSeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var eventsSeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var eventsButton: WKInterfaceButton!
    
    @IBOutlet weak var eventsLabel: WKInterfaceLabel!
    
    @IBOutlet weak var biographyLabel: WKInterfaceLabel!
    
    @IBOutlet weak var biographySeparator: WKInterfaceSeparator!
    
    // MARK: - Properties
    
    private(set) var speaker: PresentationSpeaker!
    
    private lazy var events: [Event] = Event.from(realm: Store.shared.realm.objects(RealmSummitEvent).filter({ $0.presentation?.speakers.contains({ $0.id == self.speaker.identifier }) ?? false }))
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let speakerID = (context as? Context<Identifier>)?.value,
            let realmEntity = RealmPresentationSpeaker.find(speakerID, realm: Store.shared.realm)
            else { fatalError("Invalid context") }
        
        self.speaker = PresentationSpeaker(realmEntity: realmEntity)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let summit = Summit(realmEntity: Store.shared.realm.objects(RealmSummit).first!)
        
        /// set user activity
        let activityUserInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue,
                                AppActivityUserInfo.identifier.rawValue: speaker.identifier]
        
        let webpageURL = NSURL(string: speaker.toWebpageURL(summit))!
        
        updateUserActivity(AppActivity.view.rawValue, userInfo: activityUserInfo as [NSObject : AnyObject], webpageURL: webpageURL)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    @IBAction func showEvents(sender: AnyObject? = nil) {
        
        if events.count == 1 {
            
            let event = events[0]
            
            pushControllerWithName(EventDetailInterfaceController.identifier, context: Context(event.identifier))
            
        } else {
            
            pushControllerWithName(EventsInterfaceController.identifier, context: Context(events.identifiers))
        }
    }
    
    // MARK: - Private Functions
    
    private func updateUI() {
        
        nameLabel.setText(speaker.name)
        
        titleLabel.setText(speaker.title)
        titleLabel.setHidden(speaker.title == nil)
        
        if let url = NSURL(string: speaker.pictureURL) {
            
            imageView.loadCached(url)
        }
        
        twitterLabel.setText(speaker.twitter)
        twitterGroup.setHidden(speaker.twitter == nil)
        twitterSeparator.setHidden(speaker.twitter == nil)
        
        ircLabel.setText(speaker.irc)
        ircGroup.setHidden(speaker.irc == nil)
        ircSeparator.setHidden(speaker.irc == nil)
        
        eventsLabel.setText("\(events.count) " + "\(events.count == 1 ? "session" : "sessions")")
        eventsButton.setHidden(events.count == 0)
        eventsSeparator.setHidden(events.count == 0)
        
        biographyLabel.setText(speaker.biography)
        biographyLabel.setHidden(speaker.biography == nil)
        biographySeparator.setHidden(speaker.biography == nil)
        
        if let descriptionText = speaker.biography,
            let data = descriptionText.dataUsingEncoding(NSUTF8StringEncoding),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
            
            biographyLabel.setText(attributedString.string)
            
            biographyLabel.setHidden(false)
            
        } else {
            
            biographyLabel.setHidden(true)
        }
    }
}
