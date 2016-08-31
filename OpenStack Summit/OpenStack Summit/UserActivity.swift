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
    
    /// App activity that takes you to a specific screen (usually with a list of data).
    case screen = "org.openstack.summit.viewScreen"
}

enum AppActivityUserInfo: String {
    
    // The type of summit data to be shown.
    case type
    
    // The identifier of the summit data.
    case identifier
    
    // The screen to be shown.
    case screen
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

enum AppActivityScreen: String {
    
    case venues
    case events
    case speakers
    case about
}

