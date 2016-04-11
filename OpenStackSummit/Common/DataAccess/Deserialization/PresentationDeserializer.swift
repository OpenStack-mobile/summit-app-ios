//
//  Presentation.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import Crashlytics

public class PresentationDeserializer: NSObject, IDeserializer {
    var deserializerFactory: DeserializerFactory!
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        try validateRequiredFields(["id"], inJson: json)

        let presentation = Presentation()
        presentation.id = json["id"].intValue
        presentation.level = json["level"].string ?? ""
        
        var deserializer = deserializerFactory.create(DeserializerFactoryType.Track)
        if let _ = json["track_id"].int {
            do {
                let track = try deserializer.deserialize(json["track_id"]) as! Track
                presentation.track = track
            }
            catch {
                let nsError = error as NSError
                Crashlytics.sharedInstance().recordError(nsError)
                printerr(nsError)
            }
        }
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.PresentationSpeaker)
        var presentationSpeaker : PresentationSpeaker
        if json["speakers"] != nil {
            for (_, speakerJSON) in json["speakers"] {
                presentationSpeaker = try deserializer.deserialize(speakerJSON) as! PresentationSpeaker
                presentation.speakers.append(presentationSpeaker)
            }            
        }
        
        let presentationModeratorId = json["moderator_speaker_id"]
        if (presentationModeratorId.int != nil) {
            presentation.moderator = try deserializer.deserialize(presentationModeratorId) as? PresentationSpeaker
        }
        
        return presentation
    }
}
