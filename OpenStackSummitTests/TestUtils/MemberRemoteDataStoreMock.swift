//
//  MemberRemoteDataStoreMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class MemberRemoteDataStoreMock: MemberRemoteDataStore {
    var error: NSError?
    
    init(error: NSError? = nil) {
        super.init()
        self.error = error
    }
    
    override func addEventToShedule(attendeeId: Int, eventId: Int, completionBlock: (NSError?) -> Void) {
        completionBlock(error)
    }
}
