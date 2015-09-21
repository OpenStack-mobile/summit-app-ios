//
//  SecurityManagerMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/21/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class SecurityManagerMock: SecurityManager {
    var member: Member!

    init(member: Member?) {
        self.member = member
    }
    
    override func getCurrentMember() -> Member? {
        return member
    }
}
