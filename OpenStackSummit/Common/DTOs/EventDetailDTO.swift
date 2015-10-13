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
        name = scheduleItemDTO.name
        location = scheduleItemDTO.location
        date = scheduleItemDTO.date
        sponsors = scheduleItemDTO.sponsors
        eventType = scheduleItemDTO.eventType
        credentials = scheduleItemDTO.credentials
    }
    
    public var eventDescription = ""
    public var tags = ""
    public var speakers = [PresentationSpeakerDTO]()
    public var finished = false
    public var allowFeedback = false
}