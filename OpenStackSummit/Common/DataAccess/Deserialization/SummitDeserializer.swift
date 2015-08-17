//
//  SummitDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//
import UIKit
import SwiftyJSON

public class SummitDeserializer: DeserializerProtocol {
    var deserializerStorage = DeserializerStorage()
    var deserializerFactory = DeserializerFactory()
    
    public func deserialize(json : JSON) -> BaseEntity {
        let summit = Summit()
        var deserializer : DeserializerProtocol!
        
        deserializer = deserializerFactory.create(DeserializerFactories.Company)
        var company : Company
        for (key, companyJSON) in json["companies"] {
            company = deserializer.deserialize(companyJSON) as! Company
            deserializerStorage.add(company)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactories.SummitType)
        var summitType : SummitType
        for (key, summitTypeJSON) in json["summitTypes"] {
            summitType = deserializer.deserialize(summitTypeJSON) as! SummitType
            if(!self.deserializerStorage.exist(summitType)) {
                summit.types.append(summitType)
            }
            
            deserializerStorage.add(summitType)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactories.EventType)
        var eventType : EventType
        for (key, eventTypeJSON) in json["eventTypes"] {
            eventType = deserializer.deserialize(eventTypeJSON) as! EventType
            deserializerStorage.add(eventType)
        }
        
        summit.name = json["name"].stringValue
        summit.id = json["id"].intValue
        return summit

    }
}
