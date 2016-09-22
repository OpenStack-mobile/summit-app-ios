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

// MARK: - Fetches

public extension Track {
    
    static func search(searchTerm: String, realm: Realm = Store.shared.realm) -> [Track] {
        
        return Track.from(realm: realm.objects(RealmTrack).filter("name CONTAINS [c] %@", searchTerm).sorted("name"))
    }
    
    static func `for`(groups trackGroups: [Identifier], realm: Realm = Store.shared.realm) -> [Track] {
        
        // get all local tracks
        let realmTracks = realm.objects(RealmTrack)
        
        // get all scheduled track ids
        let presentationTracks = SummitEvent.from(realm: realm.objects(RealmSummitEvent)).filter({ $0.presentation?.track != nil }).map { $0.presentation!.track! }

        var tracks = Track.from(realm: realmTracks).filter {
            
            if presentationTracks.contains($0.identifier) {
                
                return true
            }
            
            return false
        }
        
        tracks = tracks.sort { $0.name < $1.name }
        
        if trackGroups.isEmpty == false {
            
            tracks = tracks.filter { (track) in
                
                if track.groups.isEmpty == false {
                    
                    for trackGroup in track.groups {
                        
                        if trackGroups.contains(trackGroup) {
                            
                            return true
                        }
                    }
                }
                
                return false
            }
        }
        
        return tracks
    }
}

// MARK: - Encoding

extension Track: RealmDecodable {
    
    public init(realmEntity: RealmTrack) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.groups = realmEntity.trackGroups.identifiers
    }
}

extension Track: RealmEncodable {
    
    public func save(realm: Realm) -> RealmTrack {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.trackGroups.replace(with: groups)
        
        return realmEntity
    }
}