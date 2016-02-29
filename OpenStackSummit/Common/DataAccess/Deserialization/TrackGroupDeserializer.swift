//
//  TrackGroupDeserializer.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 1/18/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import SwiftyJSON

public class TrackGroupDeserializer: NamedEntityDeserializer, IDeserializer {
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json : JSON) throws -> BaseEntity {
        
        let trackGroup: TrackGroup
        
        if let trackGroupId = json.int {
            guard let check: TrackGroup = deserializerStorage.get(trackGroupId) else {
                throw DeserializerError.EntityNotFound("Track Group with id \(trackGroupId) not found on deserializer storage")
            }
            trackGroup = check
        }
        else {
            try validateRequiredFields(["id", "name"], inJson: json)
            
            trackGroup = super.deserialize(json) as TrackGroup
            trackGroup.trackGroupDescription = json["description"].stringValue
            trackGroup.color = json["color"].stringValue
            
            var track: Track
            for (_, category) in json["tracks"] {
                let trackId = category.intValue
                guard let check: Track = deserializerStorage.get(trackId) else {
                    throw DeserializerError.EntityNotFound("Track with id \(trackId) not found on deserializer storage")
                }
                track = check
                trackGroup.tracks.append(track)
                track.trackGroup = trackGroup
            }
            
            if(!deserializerStorage.exist(trackGroup)) {
                deserializerStorage.add(trackGroup)
            }
        }
        
        return trackGroup
    }
}
