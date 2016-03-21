//
//  SummitEventDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class EventDetailDTO: ScheduleItemDTO {
    
    public required init() {
        super.init()
    }
    
    public init(scheduleItemDTO: ScheduleItemDTO) {
        super.init()
        id = scheduleItemDTO.id
        name = scheduleItemDTO.name
        location = scheduleItemDTO.location
        time = scheduleItemDTO.time
        dateTime = scheduleItemDTO.dateTime
        sponsors = scheduleItemDTO.sponsors
        eventType = scheduleItemDTO.eventType
        summitTypes = scheduleItemDTO.summitTypes
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