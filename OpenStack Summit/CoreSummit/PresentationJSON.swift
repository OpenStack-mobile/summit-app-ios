//
//  PresentationJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

public extension Presentation {
    
    enum JSONKey: String {
        
        case id, level, track_id, moderator_speaker_id, speakers
    }
}

extension Presentation: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue
            else { return nil }
        
        self.identifier = identifier
        
        // optional
        if let moderator = JSONObject[JSONKey.moderator_speaker_id.rawValue]?.integerValue,
            moderator > 0 {
            
            self.moderator = moderator
            
        } else {
            
            self.moderator = nil
        }
        
        if let levelString = JSONObject[JSONKey.level.rawValue]?.rawValue as? String {
            
            guard let level = Level(rawValue: levelString)
                else { return nil }
            
            self.level = level
            
        } else {
            
            self.level = nil
        }
        
        if let speakersJSONArray = JSONObject[JSONKey.speakers.rawValue]?.arrayValue {
            
            guard let speakers = Identifier.from(json: speakersJSONArray)
                else { return nil }
            
            self.speakers = Set(speakers)
            
        } else {
            
            self.speakers = []
        }
        
    }
}
