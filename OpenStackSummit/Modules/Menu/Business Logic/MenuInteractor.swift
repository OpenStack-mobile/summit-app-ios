//
//  MenuInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMenuInteractor {
    func getCurrentMemberRole() -> MemberRoles
    func logout()
}

public class MenuInteractor: NSObject, IMenuInteractor {
    var session : ISession!
    let kCurrentMember = "currentMember"
    
    public override init() {
        super.init()
    }

    public init(session: ISession) {
        self.session = session
    }
    
    public func getCurrentMemberRole() -> MemberRoles{
        var role = MemberRoles.Anonymous
        if let member = session.get(kCurrentMember) {
            if ((member as! Member).speakerRole != nil) {
                role = MemberRoles.Speaker
            }
            else if ((member as! Member).attendeeRole != nil) {
                role = MemberRoles.Attendee
            }
        }
        return role
    }
    
    public func logout() {
        session.set(kCurrentMember, value: nil)
    }
}
