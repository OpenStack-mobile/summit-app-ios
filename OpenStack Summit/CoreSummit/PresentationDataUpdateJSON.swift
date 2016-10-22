//
//  PresentationDataUpdateJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension PresentationDataUpdate {
    
    typealias JSONKey = Presentation.JSONKey
}

extension PresentationDataUpdate: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int
            else { return nil }
        
        self.identifier = identifier
        
        // optional
        self.moderator = JSONObject[JSONKey.moderator_speaker_id.rawValue]?.rawValue as? Int
        self.track = JSONObject[JSONKey.track_id.rawValue]?.rawValue as? Int
        
        if let levelString = JSONObject[JSONKey.level.rawValue]?.rawValue as? String {
            
            guard let level = Presentation.Level(rawValue: levelString)
                else { return nil }
            
            self.level = level
            
        } else {
            
            self.level = nil
        }
        
        if let speakersJSONArray = JSONObject[JSONKey.speakers.rawValue]?.arrayValue {
            
            guard let speakers = PresentationSpeaker.fromJSON(speakersJSONArray)
                else { return nil }
            
            self.speakers = speakers
            
        } else {
            
            self.speakers = []
        }
        
    }
}
