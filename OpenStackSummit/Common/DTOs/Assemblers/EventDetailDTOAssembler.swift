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
    
    public override init() {
        super.init()
    }

    public init(speakerDTOAssembler: ISpeakerDTOAssembler) {
        self.speakerDTOAssembler = speakerDTOAssembler
    }
    
    public func createDTO(event: SummitEvent) -> EventDetailDTO {
        let eventDetailDTO = EventDetailDTO()
        
        eventDetailDTO.title = event.title
        eventDetailDTO.eventDescription = event.eventDescription
        eventDetailDTO.location = getLocation(event)
        eventDetailDTO.finished = getFinished(event)
        eventDetailDTO.date = getDate(event)
        
        if let presentation = event.presentation {
            eventDetailDTO.category = event.presentation!.category.name
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
    
    public func getDate(event: SummitEvent) -> String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
        dateFormatter.dateFormat = "EEEE dd MMMM HH:mm"
        let stringDateFrom = dateFormatter.stringFromDate(event.start)
        
        dateFormatter.dateFormat = "HH:mm"
        let stringDateTo = dateFormatter.stringFromDate(event.end)
        
        return "\(stringDateFrom) - \(stringDateTo)"
    }
    
    public func getLocation(event: SummitEvent) -> String{
        var location = event.venue!.name
        if (event.venueRoom != nil) {
            location += " - " + event.venueRoom!.name
        }
        return location
    }
    
    public func getFinished(event: SummitEvent) -> Bool{
        return event.end.compare(NSDate()) == NSComparisonResult.OrderedAscending
    }
    
    
}
