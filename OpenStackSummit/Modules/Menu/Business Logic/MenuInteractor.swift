//
//  MenuInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearOAuth2

@objc
public protocol IMenuInteractor {
}

public class MenuInteractor: NSObject, IMenuInteractor {
    var session : ISession!
    let kAccessToken = "access_token"
    let kCurrentMember = "currentMember"
    
    public override init() {
        super.init()
    }

    public init(session: ISession) {
        self.session = session
    }
}
