//
//  SummitEvent.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

public class SummitEvent: BaseEntity {

    public dynamic var end = NSDate(timeIntervalSince1970: 1)
    public dynamic var start = NSDate(timeIntervalSince1970: 1)
    public dynamic var eventDescription = ""
    public dynamic var title = ""
    public dynamic var eventType: EventType!
    public let summitTypes = List<SummitType>()
    public let sponsors = List<Company>()
    public dynamic var presentation : Presentation?
    public dynamic var venue : Venue?
    public dynamic var venueRoom : VenueRoom?
    public dynamic var timeZone = ""
}
