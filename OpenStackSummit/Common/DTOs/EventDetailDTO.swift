//
//  SummitEventDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class EventDetailDTO: ScheduleItem {
    
    public required init() {
        super.init()
    }
    
    public init(ScheduleItem: ScheduleItem) {
        super.init()
        id = ScheduleItem.id
        name = ScheduleItem.name
        location = ScheduleItem.location
        time = ScheduleItem.time
        dateTime = ScheduleItem.dateTime
        sponsors = ScheduleItem.sponsors
        eventType = ScheduleItem.eventType
        summitTypes = ScheduleItem.summitTypes
    }
    
    public var venueId: Int?
    public var eventDescription = ""
    public var tags = ""
    public var speakers = [PresentationSpeakerDTO]()
    public var finished = false
    public var allowFeedback = false
    public var moderator: PresentationSpeakerDTO?
    public var level = ""
    public var averageFeedback = 0.0
}