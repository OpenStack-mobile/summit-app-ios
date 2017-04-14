//
//  TrackGroupDataUpdateJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

extension TrackGroup.DataUpdate {
    
    typealias JSONKey = TrackGroup.JSONKey
}

extension TrackGroup.DataUpdate: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let color = JSONObject[JSONKey.color.rawValue]?.rawValue as? String,
            let tracksJSONArray = JSONObject[JSONKey.tracks.rawValue]?.arrayValue,
            let tracks = Track.from(json: tracksJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.color = color
        self.tracks = Set(tracks)
        
        // optional
        self.descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
    }
}
