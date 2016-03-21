//
//  SummitEvent.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

public class SummitEvent: NamedEntity {

    public dynamic var end = NSDate(timeIntervalSince1970: 1)
    public dynamic var start = NSDate(timeIntervalSince1970: 1)
    public dynamic var eventDescription = ""
    public dynamic var allowFeedback = false
    public dynamic var averageFeedback = 0.0
    public dynamic var eventType: EventType!
    public let summitTypes = List<SummitType>()
    public let sponsors = List<Company>()
    public let tags = List<Tag>()
    public dynamic var presentation : Presentation?
    public dynamic var venue : Venue?
    public dynamic var venueRoom : VenueRoom?
    
    public var summit: Summit {
        return try! RealmFactory().create().objects(Summit).first!
    }
}
