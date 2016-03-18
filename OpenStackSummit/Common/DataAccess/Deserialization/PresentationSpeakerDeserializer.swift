//
//  PresentationSpeakerDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class PresentationSpeakerDeserializer: NSObject, IDeserializer {
    
    var deserializerStorage: DeserializerStorage!
    
    public init(deserializerStorage: DeserializerStorage) {
        self.deserializerStorage = deserializerStorage
    }
    
    public override init() {
        super.init()
    }
    
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        var presentationSpeaker: PresentationSpeaker
        
        if let presentationSpeakerId = json.int {
            guard let check: PresentationSpeaker = deserializerStorage.get(presentationSpeakerId) else {
                throw DeserializerError.EntityNotFound("Presentation speaker with id \(presentationSpeakerId) not found on deserializer storage")
            }
            presentationSpeaker = check
        }
        else {
            try validateRequiredFields(["id"], inJson: json)
            
            presentationSpeaker = PresentationSpeaker()
            presentationSpeaker.id = json["id"].intValue
            presentationSpeaker.firstName = json["first_name"].string ?? ""
            presentationSpeaker.lastName = json["last_name"].string ?? ""
            
            if !presentationSpeaker.firstName.isEmpty {
                presentationSpeaker.fullName = presentationSpeaker.firstName
            }
            
            if !presentationSpeaker.lastName.isEmpty {
                if !presentationSpeaker.fullName.isEmpty {
                   presentationSpeaker.fullName += " "
                }
                presentationSpeaker.fullName += presentationSpeaker.lastName
            }
            
            presentationSpeaker.email = json["email"].string ?? ""
            presentationSpeaker.title = json["title"].string ?? ""
            presentationSpeaker.bio = json["bio"].string ?? ""
            presentationSpeaker.irc = json["irc"].string ?? ""
            presentationSpeaker.twitter = json["twitter"].string ?? ""
            presentationSpeaker.memberId = json["member_id"].int ?? 0
            presentationSpeaker.pictureUrl = json["pic"].string ?? ""

            deserializerStorage.add(presentationSpeaker)
        }
        return presentationSpeaker
    }
}
