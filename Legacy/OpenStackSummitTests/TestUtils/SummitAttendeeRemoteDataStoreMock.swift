//
//  SummitAttendeeRemoteDataStoreMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/21/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class SummitAttendeeRemoteDataStoreMock: SummitAttendeeRemoteDataStore {
    var error: NSError?
    
    init(error: NSError? = nil) {
        super.init()
        self.error = error
    }
    
    override func addEventToShedule(attendee: SummitAttendee, event: SummitEvent, completionBlock: (NSError?) -> Void) {
        completionBlock(error)
    }
}