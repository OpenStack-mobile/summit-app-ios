//
//  TicketTypeDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class TicketTypeDeserializer: NSObject, IDeserializer {
    var deserializerStorage: DeserializerStorage!
    var deserializerFactory: DeserializerFactory!
    
    public func deserialize(json : JSON) throws -> BaseEntity {
        
        let ticketType: TicketType
        
        if let ticketTypeId = json.int {
            ticketType = deserializerStorage.get(ticketTypeId)
        }
        else {
            try validateRequiredFields(["id", "name", "allowed_summit_types"], inJson: json)

            ticketType = TicketType()
            ticketType.id = json["id"].intValue
            ticketType.name = json["name"].stringValue
            ticketType.ticketTypeDescription = json["description"].stringValue

            var summitType: SummitType
            let deserializer = deserializerFactory.create(DeserializerFactoryType.SummitType)
            for (_, summitTypeJSON) in json["allowed_summit_types"] {
                summitType = try deserializer.deserialize(summitTypeJSON) as! SummitType
                ticketType.allowedSummitTypes.append(summitType)
            }
            
            if(!deserializerStorage.exist(ticketType)) {
                deserializerStorage.add(ticketType)
            }
        }
        
        return ticketType
    }
}
