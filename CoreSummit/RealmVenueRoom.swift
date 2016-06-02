//
//  RealmVenueRoom.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift
import Realm

public class RealmVenueRoom: RealmLocation {
    
    public dynamic var capacity = 0
    public dynamic var venue: RealmVenue!
    
    public var events: [RealmSummitEvent] {
        
        return linkingObjects(RealmSummitEvent.self, forProperty: "venueRoom")
    }
}