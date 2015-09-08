//
//  MemberProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfileWireframe {
    func showLoginView()
}

public class MemberProfileWireframe: NSObject, IMemberProfileWireframe {
    var memberProfileViewController: MemberProfileViewController!
    var loginWireframe: ILoginWireframe!
    
    public func showLoginView() {
        loginWireframe.presentLoginView(memberProfileViewController)
    }
}
