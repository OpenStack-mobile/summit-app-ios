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
    
    @IBOutlet weak var summitTypesLabel: WKInterfaceLabel!
    
    @IBOutlet weak var levelLabel: WKInterfaceLabel!
    
    @IBOutlet weak var levelGroup: WKInterfaceGroup!
    
    @IBOutlet weak var levelSeparator: WKInterfaceSeparator!
    
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    
    // MARK: - Properties
    
    private var eventDetail: EventDetail!
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let event = (context as? Context<SummitEvent>)?.value
            else { fatalError("Invalid context") }
        
        self.eventDetail = EventDetail(event: event, summit: Store.shared.cache!)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /// set user activity
        let activityUserInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue,
                                AppActivityUserInfo.identifier.rawValue: eventDetail.identifier]
        
        updateUserActivity(AppActivity.view.rawValue, userInfo: activityUserInfo as [NSObject : AnyObject], webpageURL: eventDetail.webpageURL)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        nameLabel.setText(eventDetail.name)
        
        if let video = eventDetail.video,
            let url = NSURL(string: "https://img.youtube.com/vi/" + video.youtube + "/default.jpg"),
            let data = NSData(contentsOfURL: url) {
            
            moviePlayer.setHidden(false)
            moviePlayer.setPosterImage(WKImage(imageData: data))
            
        } else {
            
            moviePlayer.setHidden(true)
        }
        
        dateLabel.setText(eventDetail.dateTime)
        locationLabel.setText(eventDetail.location)
        locationButton.setHidden(eventDetail.location.isEmpty)
        locationSeparator.setHidden(eventDetail.location.isEmpty)
        tagsLabel.setText(eventDetail.tags)
        tagsGroup.setHidden(eventDetail.tags.isEmpty)
        speakersLabel.setText("\(eventDetail.speakers.count) \(eventDetail.speakers.count == 1 ? "speaker" : "speakers")")
        summitTypesLabel.setText(eventDetail.summitTypes)
        levelLabel.setText(eventDetail.level)
        levelGroup.setHidden(eventDetail.level.isEmpty)
        
        if let descriptionText = eventDetail.descriptionText,
            let data = descriptionText.dataUsingEncoding(NSUTF8StringEncoding),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
            
            descriptionLabel.setText(attributedString.string)
            
            descriptionLabel.setHidden(false)
            
        } else {
            
            descriptionLabel.setHidden(true)
        }
    }
}