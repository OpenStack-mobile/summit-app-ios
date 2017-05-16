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
    
    @IBOutlet private(set) weak var nameLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var titleLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var imageView: WKInterfaceImage!
    
    @IBOutlet private(set) weak var twitterLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var twitterGroup: WKInterfaceGroup!
    
    @IBOutlet private(set) weak var twitterSeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var ircLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var ircGroup: WKInterfaceGroup!
    
    @IBOutlet private(set) weak var ircSeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var eventsSeparator: WKInterfaceSeparator!
    
    @IBOutlet private(set) weak var eventsButton: WKInterfaceButton!
    
    @IBOutlet private(set) weak var eventsLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var biographyLabel: WKInterfaceLabel!
    
    @IBOutlet private(set) weak var biographySeparator: WKInterfaceSeparator!
    
    // MARK: - Properties
    
    private(set) var speaker: Speaker!
    
    private lazy var events: [Event] = Store.shared.cache?.schedule.filter({ $0.presentation.speakers.contains(self.speaker.identifier)}) ?? []
    
    // MARK: - Loading
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let speaker = (context as? Context<Speaker>)?.value
            else { fatalError("Invalid context") }
        
        self.speaker = speaker
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /// set user activity
        let activityUserInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue,
                                AppActivityUserInfo.identifier.rawValue: speaker.identifier] as [String : Any]
        
        let webpageURL = speaker.webpage(for: Store.shared.cache!)
        
        updateUserActivity(AppActivity.view.rawValue, userInfo: activityUserInfo as [AnyHashable: Any], webpageURL: webpageURL)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    @IBAction func showEvents(_ sender: AnyObject? = nil) {
        
        if events.count == 1 {
            
            let event = events[0]
            
            pushController(withName: EventDetailInterfaceController.identifier, context: Context(event))
            
        } else {
            
            pushController(withName: EventsInterfaceController.identifier, context: Context(events))
        }
    }
    
    // MARK: - Private Functions
    
    private func updateUI() {
        
        nameLabel.setText(speaker.name)
        
        titleLabel.setText(speaker.title)
        titleLabel.setHidden(speaker.title == nil)
        
        imageView.loadCached(speaker.picture)
        
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
            let data = descriptionText.data(using: String.Encoding.utf8),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            
            biographyLabel.setText(attributedString.string)
            
            biographyLabel.setHidden(false)
            
        } else {
            
            biographyLabel.setHidden(true)
        }
    }
}
