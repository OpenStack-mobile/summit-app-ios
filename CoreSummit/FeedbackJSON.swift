//
//  FeedbackJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Feedback {
    
    enum JSONKey: String {
        
        case id, event_id, rate, note, created_date, attendee_id, owner_id, owner
    }
}


