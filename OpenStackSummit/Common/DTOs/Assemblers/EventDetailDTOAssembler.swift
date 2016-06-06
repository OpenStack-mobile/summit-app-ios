//
//  EventDetailDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventDetailDTOAssembler {
    func createDTO(event: SummitEvent) -> EventDetailDTO
}

public class EventDetailDTOAssembler: NSObject, IEventDetailDTOAssembler {
    var speakerDTOAssembler: IPresentationSpeakerDTOAssembler!
    var ScheduleItemAssembler: IScheduleItemAssembler!
    
    public override init() {
        super.init()
    }

    public init(speakerDTOAssembler: IPresentationSpeakerDTOAssembler, ScheduleItemAssembler: IScheduleItemAssembler) {
        self.speakerDTOAssembler = speakerDTOAssembler
        self.ScheduleItemAssembler = ScheduleItemAssembler
    }
    
    public func createDTO(event: SummitEvent) -> EventDetailDTO {
        let ScheduleItem = ScheduleItemAssembler.createDTO(event)
        let eventDetailDTO = EventDetailDTO(ScheduleItem: ScheduleItem)
        
        eventDetailDTO.venueId = event.venue?.id
        if let venueRoom = event.venueRoom {
            eventDetailDTO.venueId = venueRoom.venue.id
        }
        
        eventDetailDTO.finished = getFinished(event)
        eventDetailDTO.eventDescription = event.eventDescription
        eventDetailDTO.allowFeedback = event.allowFeedback
        eventDetailDTO.averageFeedback = event.averageFeedback
        eventDetailDTO.tags = getTags(event)
        eventDetailDTO.level = event.presentation != nil ? event.presentation!.level + " Level" : ""
        
        if let presentation = event.presentation {
            eventDetailDTO.track = event.presentation!.track != nil ? event.presentation!.track!.name : ""
            
            var speakerDTO: PresentationSpeakerDTO
            for speaker in presentation.speakers {
                // HACK: dismiss speakers with empty name
                if speaker.fullName.isEmpty {
                    continue
                }
                speakerDTO = speakerDTOAssembler.createDTO(speaker)
                eventDetailDTO.speakers.append(speakerDTO)
            }
            
            if let moderator = event.presentation?.moderator {
                eventDetailDTO.moderator = speakerDTOAssembler.createDTO(moderator)
            }
        }
        
        return eventDetailDTO
    }
    
    public func getTags(event: SummitEvent) -> String {
        var tags = ""
        var separator = ""
        for tag in event.tags {
            tags += separator + tag.name
            separator = ", "
        }
        return tags
    }
        
    public func getFinished(event: SummitEvent) -> Bool{
        return event.end.compare(NSDate()) == NSComparisonResult.OrderedAscending
    }
}
