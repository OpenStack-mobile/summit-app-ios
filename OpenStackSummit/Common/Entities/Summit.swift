//
//  Summit.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

public class Summit: NamedEntity {
    public dynamic var startDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var endDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var timeZone = ""
    public dynamic var initialDataLoadDate = NSDate(timeIntervalSince1970: 1)
    public let types = List<SummitType>()
    public let ticketTypes = List<TicketType>()
    public let venues = List<Venue>()
    public let events = List<SummitEvent>()
    public let track = List<Track>()
    public let eventTypes = List<EventType>()
}
