//
//  MenuInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol MenuInteractorProtocol {
    func getCurrentMemberRole() -> MemberRoles
}

public class MenuInteractor: NSObject, MenuInteractorProtocol {
    var session : SessionProtocol!
    
    public override init() {
        super.init()
    }

    public init(session: SessionProtocol) {
        self.session = session
    }
    
    public func getCurrentMemberRole() -> MemberRoles{
        var role = MemberRoles.Anonymous
        if let member = session.get("currentMember") {
            if ((member as! Member).speakerRole != nil) {
                role = MemberRoles.Speaker
            }
            else if ((member as! Member).attendeeRole != nil) {
                role = MemberRoles.Attendee
            }
        }
        return role
    }
}
