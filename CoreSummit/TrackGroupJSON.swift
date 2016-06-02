//
//  TrackGroupJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension TrackGroup {
    
    enum JSONKey: String {
        
        case id, name, color, description, tracks
    }
}

extension TrackGroup: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let color = JSONObject[JSONKey.color.rawValue]?.rawValue as? String,
            let description = JSONObject[JSONKey.description.rawValue]?.rawValue as? String,
            let tracksJSONArray = JSONObject[JSONKey.tracks.rawValue]?.arrayValue,
            let tracks = Int.fromJSON(tracksJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.color = color
        self.descriptionText = description
        self.tracks = tracks
    }
}