//
//  SummitAttendeeJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

public extension Attendee {
    
    enum JSONKey: String {
        
        case id, summit_hall_checked_in, summit_hall_checked_in_date, shared_contact_info, member_id, schedule, tickets
    }
}

extension Attendee: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let member = JSONObject[JSONKey.member_id.rawValue]?.integerValue,
            let scheduledEventsJSONArray = JSONObject[JSONKey.schedule.rawValue]?.arrayValue,
            let scheduledEvents = Identifier.from(json: scheduledEventsJSONArray),
            let ticketsJSONArray = JSONObject[JSONKey.tickets.rawValue]?.arrayValue,
            let tickets = Identifier.from(json: ticketsJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.member = member
        self.schedule = Set(scheduledEvents)
        self.tickets = Set(tickets)
    }
}
