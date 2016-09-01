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
    
    @IBOutlet weak var tagsLabel: WKInterfaceLabel!
    
    @IBOutlet weak var speakersLabel: WKInterfaceLabel!
    
    @IBOutlet weak var summitTypesLabel: WKInterfaceLabel!
    
    @IBOutlet weak var levelLabel: WKInterfaceLabel!
    
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
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Actions
    
    
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        nameLabel.setText(eventDetail.name)
        
        if let youtube = eventDetail.video?.youtube,
            let url = NSURL(string: "http://img.youtube.com/vi/" + youtube + "/default.jpg"),
            let data = NSData(contentsOfURL: url) {
                
            moviePlayer.setPosterImage(WKImage(imageData: data))
        }
        
        dateLabel.setText(eventDetail.dateTime)
        locationLabel.setText(eventDetail.location)
        locationLabel.setHidden(eventDetail.location.isEmpty)
        locationSeparator.setHidden(eventDetail.location.isEmpty)
        tagsLabel.setText(eventDetail.tags)
        speakersLabel.setText("\(eventDetail.speakers.count) \(eventDetail.speakers.count == 1 ? "speaker" : "speakers")")
        summitTypesLabel.setText(eventDetail.summitTypes)
        levelLabel.setText(eventDetail.level)
        descriptionLabel.setText(eventDetail.descriptionText)
        descriptionLabel.setHidden((eventDetail.descriptionText ?? "").isEmpty)
    }
}