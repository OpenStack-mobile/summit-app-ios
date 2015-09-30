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
    func getByIdFromLocal(id: Int) -> Member? { return nil }
    func addEventToMemberShedule(member: Member, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void) {}
    func getLoggedInMemberFromOrigin(completionBlock : (Member?, NSError?) -> Void) {}
}
