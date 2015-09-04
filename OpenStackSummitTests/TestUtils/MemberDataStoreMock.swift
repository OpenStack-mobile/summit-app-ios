//
//  MemberDataStoreMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class MemberDataStoreMock: NSObject, IMemberDataStore {
    func getById(id: Int, completionBlock : (Member?, NSError?) -> Void) {}
    func getByEmail(email: String, completionBlock : (Member?, NSError?) -> Void) {}
    func addEventToMemberShedule(memberId: Int, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void) {}

}
