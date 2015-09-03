//
//  MemberProfileInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfileInteractor {
    func getCurrentMember() -> Member?
    func getMember(memberId: Int, completionBlock : (Member?, NSError?) -> Void)
    func isFullProfileAllowed(member: Member) -> Bool
}

public class MemberProfileInteractor: NSObject, IMemberProfileInteractor {
    var memberDataStore: IMemberDataStore!
    var session: ISession!

    let kCurrentMember = "currentMember"

    public func getMember(memberId: Int, completionBlock : (Member?, NSError?) -> Void) {
        memberDataStore.getById(memberId, completionBlock: completionBlock)
    }

    public func getCurrentMember() -> Member?{
        let member = session.get(kCurrentMember) as? Member
        return member
    }
    
    public func isFullProfileAllowed(member: Member) -> Bool {
        return true
    }
}
