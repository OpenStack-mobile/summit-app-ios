//
//  DeserializerFactory.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public enum DeserializerFactories {
    case Member, Company, EventType, SummitType, Summit, SummitLocation, Venue, VenueRoom, SummitEvent, Presentation, PresentationCategory, Tag, PresentationSpeaker
}

public class DeserializerFactory : NSObject {
    var summitDeserializer: SummitDeserializer!
    var companyDeserializer: CompanyDeserializer!
    var eventTypeDeserializer: EventTypeDeserializer!
    var summitTypeDeserializer: SummitTypeDeserializer!
    var summitLocationDeserializer: SummitLocationDeserializer!
    var venueDeserializer: VenueDeserializer!
    var venueRoomDeserializer: VenueRoomDeserializer!
    var summitEventDeserializer: SummitEventDeserializer!
    var presentationDeserializer: PresentationDeserializer!
    var memberDeserializer: MemberDeserializer!
    var presentationSpeakerDeserializer: PresentationSpeakerDeserializer!
    var presentationCategoryDeserializer: PresentationCategoryDeserializer!
    var tagDeserializer: TagDeserializer!
    
    public func create(type: DeserializerFactories) -> DeserializerProtocol {
        var deserializer : DeserializerProtocol!
        
        switch type {
        case DeserializerFactories.Summit:
            deserializer = summitDeserializer
        case DeserializerFactories.Company:
            deserializer = companyDeserializer
        case DeserializerFactories.EventType:
            deserializer = eventTypeDeserializer
        case DeserializerFactories.SummitType:
            deserializer = summitTypeDeserializer
        case DeserializerFactories.SummitLocation:
            deserializer = summitLocationDeserializer
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
        case DeserializerFactories.PresentationCategory:
            deserializer = presentationCategoryDeserializer
        case DeserializerFactories.Tag:
            deserializer = tagDeserializer
        default:
            NSException(name: "InvalidArgument",reason: "Type \(type) is an unexpected deserializer type", userInfo: nil).raise()
        }
        
        return deserializer!
    }
}
