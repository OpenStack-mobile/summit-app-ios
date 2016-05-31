//
//  RealmSummitAttendee.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmSummitAttendee: RealmPerson {
    
    public let tickets = List<RealmTicketType>()
    public let scheduledEvents = List<RealmSummitEvent>()
    public let bookmarkedEvents = List<RealmSummitEvent>()
    public let friends = List<RealmMember>()
    public let feedback = List<RealmFeedback>()
}
