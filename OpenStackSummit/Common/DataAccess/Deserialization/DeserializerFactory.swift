//
//  DeserializerFactory.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public enum DeserializerFactories {
    case Member, Company, EventType, SummitType, Summit, Location, Venue, VenueRoom, SummitEvent, Presentation, Track, Tag, PresentationSpeaker, Image, TicketType, SummitAttendee
}

public class DeserializerFactory : NSObject {
    var summitDeserializer: SummitDeserializer!
    var companyDeserializer: CompanyDeserializer!
    var eventTypeDeserializer: EventTypeDeserializer!
    var summitTypeDeserializer: SummitTypeDeserializer!
    var locationDeserializer: LocationDeserializer!
    var venueDeserializer: VenueDeserializer!
    var venueRoomDeserializer: VenueRoomDeserializer!
    var summitEventDeserializer: SummitEventDeserializer!
    var presentationDeserializer: PresentationDeserializer!
    var memberDeserializer: MemberDeserializer!
    var presentationSpeakerDeserializer: PresentationSpeakerDeserializer!
    var trackDeserializer: TrackDeserializer!
    var tagDeserializer: TagDeserializer!
    var imageDeserializer: ImageDeserializer!
    var ticketTypeDeserializer: TicketTypeDeserializer!
    var summitAttendeeDeserializer: SummitAttendeeDeserializer!
    
    public func create(type: DeserializerFactories) -> IDeserializer {
        var deserializer : IDeserializer!
        
        switch type {
        case DeserializerFactories.Summit:
            deserializer = summitDeserializer
        case DeserializerFactories.Company:
            deserializer = companyDeserializer
        case DeserializerFactories.EventType:
            deserializer = eventTypeDeserializer
        case DeserializerFactories.SummitType:
            deserializer = summitTypeDeserializer
        case DeserializerFactories.Location:
            deserializer = locationDeserializer
        case DeserializerFactories.Venue:
            deserializer = venueDeserializer
        case DeserializerFactories.VenueRoom:
            deserializer = venueRoomDeserializer
        case DeserializerFactories.SummitEvent:
            deserializer = summitEventDeserializer
        case DeserializerFactories.Presentation:
            deserializer = presentationDeserializer
        case DeserializerFactories.Member:
            deserializer = memberDeserializer
        case DeserializerFactories.PresentationSpeaker:
            deserializer = presentationSpeakerDeserializer
        case DeserializerFactories.Track:
            deserializer = trackDeserializer
        case DeserializerFactories.Tag:
            deserializer = tagDeserializer
        case DeserializerFactories.Image:
            deserializer = imageDeserializer
        case DeserializerFactories.TicketType:
            deserializer = ticketTypeDeserializer
        case DeserializerFactories.SummitAttendee:
            deserializer = summitAttendeeDeserializer
        default:
            NSException(name: "InvalidArgument",reason: "Type \(type) is an unexpected deserializer type", userInfo: nil).raise()
        }
        
        return deserializer!
    }
}
