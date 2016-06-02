//
//  VenueRoom.swift
//  
//
//  Created by Claudio on 8/12/15.
//
//

import Foundation
import RealmSwift

public class VenueRoom: Location {

    public dynamic var capacity = 0
    public dynamic var venue: Venue!
    
    public var events: [SummitEvent] { return []
        //return (self as RealmSwift.Object).linkingObjects(SummitEvent.self, forProperty: "venueRoom")
    }
}
