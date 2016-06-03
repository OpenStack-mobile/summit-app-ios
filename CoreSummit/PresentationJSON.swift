//
//  PresentationJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Presentation {
    
    enum JSONKey: String {
        
        case id, level, track_id, moderator_speaker_id, speakers
    }
}

extension Presentation: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let level = JSONObject[JSONKey.level.rawValue]?.rawValue as? String,
            let trackIdentifier = JSONObject[JSONKey.track_id.rawValue]?.rawValue as? Int,
            let speakersJSONArray = JSONObject[JSONKey.speakers.rawValue]?.arrayValue,
            let speakers = Int.fromJSON(speakersJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.level = level
        self.track = trackIdentifier
        self.speakers = speakers
        
        // optional
        self.moderator = JSONObject[JSONKey.moderator_speaker_id.rawValue]?.rawValue as? Int ?? nil
    }
}