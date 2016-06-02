//
//  RealmEventType.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmEventType: RealmNamed { }

// MARK: - Encoding

extension EventType: RealmDecodable {
    
    public init(realmEntity: RealmEventType) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
    }
}