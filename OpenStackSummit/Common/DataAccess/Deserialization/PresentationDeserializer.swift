//
//  Presentation.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class PresentationDeserializer: NSObject, IDeserializer {
    var deserializerFactory: DeserializerFactory!
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        try validateRequiredFields(["id", "level", "track_id", "speakers"], inJson: json)

        let presentation = Presentation()
        presentation.id = json["id"].intValue
        presentation.level = json["level"].stringValue
        
        var deserializer = deserializerFactory.create(DeserializerFactoryType.Track)
        let track = try deserializer.deserialize(json["track_id"]) as! Track
        presentation.track = track
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.PresentationSpeaker)
        var presentationSpeaker : PresentationSpeaker
        for (_, speakerJSON) in json["speakers"] {
            presentationSpeaker = try deserializer.deserialize(speakerJSON) as! PresentationSpeaker
            presentation.speakers.append(presentationSpeaker)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.Tag)
        var tag : Tag
        for (_, tagsJSON) in json["tags"] {
            tag = try deserializer.deserialize(tagsJSON) as! Tag
            presentation.tags.append(tag)
        }
        
        return presentation
    }
}
