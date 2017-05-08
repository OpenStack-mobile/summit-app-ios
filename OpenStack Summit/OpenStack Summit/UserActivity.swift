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

protocol AppActivitySummitData {
    
    static var activityDataType: AppActivitySummitDataType { get }
}

enum AppActivitySummitDataType: String {
    
    case event
    case speaker
    case video
    case venue
    case venueRoom
    
    var managedObject: Entity.Type {
        
        switch self {
        case .event: return EventManagedObject.self
        case .speaker: return SpeakerManagedObject.self
        case .video: return VideoManagedObject.self
        case .venue: return VenueManagedObject.self
        case .venueRoom: return VenueRoomManagedObject.self
        }
    }
}

enum AppActivityScreen: String {
    
    case venues
    case events
    case speakers
    case about
    case inbox
}

// MARK: - Model Extensions

extension Event: AppActivitySummitData {
    
    static let activityDataType = AppActivitySummitDataType.event
}

extension Speaker: AppActivitySummitData {
    
    static let activityDataType = AppActivitySummitDataType.speaker
}

extension Video: AppActivitySummitData {
    
    static let activityDataType = AppActivitySummitDataType.video
}

extension Venue: AppActivitySummitData {
    
    static let activityDataType = AppActivitySummitDataType.venue
}

extension VenueRoom: AppActivitySummitData {
    
    static let activityDataType = AppActivitySummitDataType.venueRoom
}

// MARK: - WebConvertible

extension AppActivitySummitDataType {
    
    init(webPathComponent: WebPathComponent) {
        
        switch webPathComponent {
        case .events: self = .event
        case .speakers: self = .speaker
        }
    }
}
