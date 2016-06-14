//
//  DeserializerFactory.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public enum DeserializerFactoryError: ErrorType {
    case InvalidClassName
}

public enum DeserializerFactoryType {
    case Member, Company, EventType, SummitType, Summit, Location, Venue, VenueRoom, SummitEvent, Presentation, Track, TrackGroup, Tag, PresentationSpeaker, Image, TicketType, SummitAttendee, DataUpdate, Feedback, NonConfirmedSummitAttendee
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
    var trackGroupDeserializer: TrackGroupDeserializer!
    var tagDeserializer: TagDeserializer!
    var imageDeserializer: ImageDeserializer!
    var ticketTypeDeserializer: TicketTypeDeserializer!
    var summitAttendeeDeserializer: SummitAttendeeDeserializer!
    var dataUpdateDeserializer: DataUpdateDeserializer!
    var feedbackDeserializer: FeedbackDeserializer!
    var nonConfirmedSummitAttendeeDeserializer: NonConfirmedSummitAttendeeDeserializer!
    
    public func create(type: DeserializerFactoryType) -> IDeserializer {
        var deserializer : IDeserializer!
        
        switch type {
        case DeserializerFactoryType.Summit:
            deserializer = summitDeserializer
        case DeserializerFactoryType.Company:
            deserializer = companyDeserializer
        case DeserializerFactoryType.EventType:
            deserializer = eventTypeDeserializer
        case DeserializerFactoryType.SummitType:
            deserializer = summitTypeDeserializer
        case DeserializerFactoryType.Location:
            deserializer = locationDeserializer
        case DeserializerFactoryType.Venue:
            deserializer = venueDeserializer
        case DeserializerFactoryType.VenueRoom:
            deserializer = venueRoomDeserializer
        case DeserializerFactoryType.SummitEvent:
            deserializer = summitEventDeserializer
        case DeserializerFactoryType.Presentation:
            deserializer = presentationDeserializer
        case DeserializerFactoryType.Member:
            deserializer = memberDeserializer
        case DeserializerFactoryType.PresentationSpeaker:
            deserializer = presentationSpeakerDeserializer
        case DeserializerFactoryType.Track:
            deserializer = trackDeserializer
        case DeserializerFactoryType.TrackGroup:
            deserializer = trackGroupDeserializer
        case DeserializerFactoryType.Tag:
            deserializer = tagDeserializer
        case DeserializerFactoryType.Image:
            deserializer = imageDeserializer
        case DeserializerFactoryType.TicketType:
            deserializer = ticketTypeDeserializer
        case DeserializerFactoryType.SummitAttendee:
            deserializer = summitAttendeeDeserializer
        case DeserializerFactoryType.DataUpdate:
            deserializer = dataUpdateDeserializer
        case DeserializerFactoryType.Feedback:
            deserializer = feedbackDeserializer
        case DeserializerFactoryType.NonConfirmedSummitAttendee:
            deserializer = nonConfirmedSummitAttendeeDeserializer
        }
        
        return deserializer!
    }
    
    public func create(className: String) throws -> IDeserializer? {
        var deserializer : IDeserializer!
        
        switch className {
        case "Summit":
            deserializer = summitDeserializer
        case "MySchedule":
            deserializer = summitEventDeserializer
        case "Presentation":
            deserializer = summitEventDeserializer
        case "SummitEvent":
            deserializer = summitEventDeserializer
        case "SummitType":
            deserializer = summitTypeDeserializer
        case "SummitEventType":
            deserializer = eventTypeDeserializer
        case "PresentationSpeaker":
            deserializer = presentationSpeakerDeserializer
        case "SummitTicketType":
            deserializer = ticketTypeDeserializer
        case "SummitVenue":
            deserializer = venueDeserializer
        case "SummitVenueRoom":
            deserializer = venueRoomDeserializer
        case "PresentationCategory":
            deserializer = trackDeserializer
        case "PresentationCategoryGroup":
            deserializer = trackGroupDeserializer
        case "SummitLocationMap":
            deserializer = imageDeserializer
        case "SummitLocationImage":
            deserializer = imageDeserializer
        default:
            printerr("There is no deserializer for class \(className)")
        }
        
        return deserializer
    }
}
