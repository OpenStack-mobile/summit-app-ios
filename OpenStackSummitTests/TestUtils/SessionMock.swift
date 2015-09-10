//
//  SessionMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class SessionMock: NSObject, ISession {
    var member: Member?
    
    override init() {
        super.init()
    }
    
    init (member: Member?) {
        self.member = member
    }
    
    func get(key: String) -> AnyObject? {
        
        if (key == "currentMember") {
            return member
        }
        return nil
    }
    
    func set(key: String, value: AnyObject?) {
        
    }
}
