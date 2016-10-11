//
//  TrackGroupDataUpdateJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension TrackGroupDataUpdate {
    
    typealias JSONKey = TrackGroup.JSONKey
}

extension TrackGroupDataUpdate: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let color = JSONObject[JSONKey.color.rawValue]?.rawValue as? String,
            let tracksJSONArray = JSONObject[JSONKey.tracks.rawValue]?.arrayValue,
            let tracks = Track.fromJSON(tracksJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.color = color
        self.tracks = tracks
        
        // optional
        self.descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
    }
}