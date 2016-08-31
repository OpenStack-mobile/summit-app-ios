//
//  UserActivity.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit

/// `NSUserActivity` type
enum AppActivity: String {
    
    /// App activity for handoff of summit data viewing.
    case view = "org.openstack.summit.viewSummit"
}

enum AppActivityUserInfo: String {
    
    // The type of summit data to be shown.
    case type
    
    // the identifier of the summit data.
    case identifier
}

enum AppActivitySummitDataType: String {
    
    case event
    case speaker
    case video
    case venue
    case venueRoom
    
    var realmType: RealmEntity.Type {
        
        switch self {
            
        case .event: return RealmSummitEvent.self
        case .speaker: return RealmPresentationSpeaker.self
        case .video: return RealmVideo.self
        case .venue: return RealmVenue.self
        case .venueRoom: return RealmVenueRoom.self
        }
    }
}

