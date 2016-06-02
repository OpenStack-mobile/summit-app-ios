//
//  RealmTrack.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmTrack: RealmNamed {
    
    public let trackGroups = List<RealmTrackGroup>()
}

// MARK: - Encoding

extension Track: RealmDecodable {
    
    public init(realmEntity: RealmTrack) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.groups = realmEntity.trackGroups.map { $0.id }
    }
}