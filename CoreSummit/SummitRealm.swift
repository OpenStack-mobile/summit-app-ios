//
//  RealmSummit.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

import RealmSwift

public class RealmSummit: RealmNamed {
    public dynamic var startDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var endDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var timeZone = ""
    public dynamic var initialDataLoadDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var startShowingVenuesDate = NSDate(timeIntervalSince1970: 1)
    public let types = List<RealmSummitType>()
    public let ticketTypes = List<RealmTicketType>()
    public let venues = List<RealmVenue>()
    public let venuesRooms = List<RealmVenueRoom>()
    public let events = List<RealmSummitEvent>()
    public let track = List<RealmTrack>()
    public let trackGroups = List<RealmTrackGroup>()
    public let eventTypes = List<RealmEventType>()
}

