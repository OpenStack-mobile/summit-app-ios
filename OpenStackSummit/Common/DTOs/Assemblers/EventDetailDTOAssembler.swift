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
    var speakerDTOAssembler: ISpeakerDTOAssembler!
    var scheduleItemDTOAssembler: IScheduleItemDTOAssembler!
    
    public override init() {
        super.init()
    }

    public init(speakerDTOAssembler: ISpeakerDTOAssembler, scheduleItemDTOAssembler: IScheduleItemDTOAssembler) {
        self.speakerDTOAssembler = speakerDTOAssembler
        self.scheduleItemDTOAssembler = scheduleItemDTOAssembler
    }
    
    public func createDTO(event: SummitEvent) -> EventDetailDTO {
        let scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
        let eventDetailDTO = EventDetailDTO(scheduleItemDTO: scheduleItemDTO)
        eventDetailDTO.finished = getFinished(event)
        eventDetailDTO.eventDescription = event.eventDescription
        if let presentation = event.presentation {
            eventDetailDTO.track = event.presentation!.track.name
            eventDetailDTO.tags = getTags(presentation)
            
            var speakerDTO: SpeakerDTO
            for speaker in presentation.speakers {
                speakerDTO = speakerDTOAssembler.createDTO(speaker)
                eventDetailDTO.speakers.append(speakerDTO)
            }
        }
        return eventDetailDTO
    }
    
    public func getTags(presentation: Presentation) -> String {
        var tags = ""
        var separator = ""
        for tag in presentation.tags {
            tags += separator + tag.name
            separator = ", "
        }
        return tags
    }
        
    public func getFinished(event: SummitEvent) -> Bool{
        return event.end.compare(NSDate()) == NSComparisonResult.OrderedAscending
    }
}
