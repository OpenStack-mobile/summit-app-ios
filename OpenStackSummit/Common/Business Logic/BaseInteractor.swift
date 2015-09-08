//
//  BaseInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IBaseInteractor {
    func isLoggedIn() -> Bool
    func getCurrentMember() -> Member?
}

public class BaseInteractor: NSObject, IBaseInteractor {
    var session: ISession!
    
    let kCurrentMember = "currentMember"
    
    public override init() {
        super.init()
    }
    
    public init(session: ISession) {
        self.session = session
    }
    
    public func isLoggedIn() -> Bool {
        return session.get(kCurrentMember) != nil
    }
    
    public func getCurrentMember() -> Member? {
        let member = session.get(kCurrentMember) as? Member
        return member
    }    
}
