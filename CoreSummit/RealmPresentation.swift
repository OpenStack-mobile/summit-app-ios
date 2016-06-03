//
//  RealmPresentation.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmPresentation: RealmEntity {
    
    public dynamic var level = ""
    public dynamic var track: RealmTrack?
    public dynamic var moderator: RealmPresentationSpeaker?
    public let speakers = List<RealmPresentationSpeaker>()
    
    
    public var event: RealmSummitEvent {
        return self.linkingObjects(RealmSummitEvent.self, forProperty: "presentation").first!
    }
}

// MARK: - Encoding

extension Presentation: RealmDecodable {
    
    public init(realmEntity: RealmPresentation) {
        
        self.identifier = realmEntity.id
        self.level = Level(rawValue: realmEntity.level)
        self.track = realmEntity.track!.id
        self.moderator = realmEntity.moderator?.id
        self.speakers = realmEntity.speakers.identifiers
    }
}

