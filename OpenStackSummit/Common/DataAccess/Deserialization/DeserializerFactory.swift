//
//  DeserializerFactory.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public enum DeserializerFactories {
    case Company, EventType, SummitType, Summit, SummitLocation, Venue, VenueRoom
}

public class DeserializerFactory {

    public func create(type: DeserializerFactories) -> DeserializerProtocol {
        var deserializer : DeserializerProtocol!
        
        switch type {
        case DeserializerFactories.Company:
            deserializer = CompanyDeserializer()
        case DeserializerFactories.EventType:
            deserializer = EventTypeDeserializer()
        case DeserializerFactories.SummitType:
            deserializer = SummitTypeDeserializer()
        case DeserializerFactories.SummitLocation:
            deserializer = SummitLocationDeserializer()
        case DeserializerFactories.Venue:
            deserializer = VenueDeserializer()
        case DeserializerFactories.VenueRoom:
            deserializer = VenueRoomDeserializer()
        default:
            NSException(name: "InvalidArgument",reason: "Type \(type) is an unexpected deserializer type", userInfo: nil).raise()
        }
        
        return deserializer!
    }
}
