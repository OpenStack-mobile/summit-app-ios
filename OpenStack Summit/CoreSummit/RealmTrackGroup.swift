//
//  RealmTrackGroup.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmTrackGroup: RealmNamed {
    
    public dynamic var color = ""
    public dynamic var trackGroupDescription = ""
    public let tracks = List<RealmTrack>()
}

extension TrackGroup: RealmDecodable {
    
    public init(realmEntity: RealmTrackGroup) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.descriptionText = String(realm: realmEntity.trackGroupDescription)
        self.color = realmEntity.color
        self.tracks = realmEntity.tracks.identifiers
    }
}

extension TrackGroup: RealmEncodable {
    
    public func save(realm: Realm) -> RealmTrackGroup {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.color = color
        realmEntity.trackGroupDescription = descriptionText ?? ""
        realmEntity.tracks.replace(with: tracks)
        
        return realmEntity
    }
}

// MARK: - Fetches

public extension RealmTrackGroup {
    
    static var sortProperties: [RealmSwift.SortDescriptor] {
        
        return [SortDescriptor(property: "name", ascending: true)]
    }
}

public extension TrackGroup {
    
    /// Fetch all track groups that have some event associated with them. 
    static func scheduled(realm: Realm = Store.shared.realm) -> [TrackGroup] {
        
        let tracks = realm.objects(RealmSummitEvent).filter("presentation.track.id > 0").map { $0.presentation!.track! }
        
        let trackGroups = realm.objects(RealmTrackGroup).filter("ANY %@ IN tracks.id", tracks.map({ $0.id })).sorted(RealmTrackGroup.sortProperties)
        
        return TrackGroup.from(realm: trackGroups)
    }
}
