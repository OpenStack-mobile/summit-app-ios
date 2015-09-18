//
//  SummitAttendee.swift
//  
//
//  Created by Claudio on 8/12/15.
//
//

import Foundation
import RealmSwift

public class SummitAttendee: BaseEntity {
    public var ticketType: TicketType!
    public let scheduledEvents = List<SummitEvent>()
    public let bookmarkedEvents = List<SummitEvent>()
    public let friends = List<Member>()
    
}
