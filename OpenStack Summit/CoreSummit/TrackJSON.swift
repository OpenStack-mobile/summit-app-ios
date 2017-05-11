//
//  TrackJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

private extension Track {
    
    enum JSONKey: String {
        
        case id, name, track_groups
    }
}

extension Track: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let trackGroupsJSONArray = JSONObject[JSONKey.track_groups.rawValue]?.arrayValue,
            let trackGroups = Identifier.from(json: trackGroupsJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.groups = Set(trackGroups)
    }
}

extension MemberResponse.Track: JSONDecodable {
    
    private typealias JSONKey = Track.JSONKey
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let trackGroupsJSONArray = JSONObject[JSONKey.track_groups.rawValue]?.arrayValue,
            let trackGroups = TrackGroup.from(json: trackGroupsJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.groups = trackGroups
    }
}
