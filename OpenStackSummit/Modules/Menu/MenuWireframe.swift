//
//  MenuWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMenuWireframe {
    func showMyProfile(memberId: Int)
}

public class MenuWireframe: NSObject, IMenuWireframe {
    
    var menuViewController: MenuViewController!
    
    var memberProfileWireframe: IMemberProfileWireframe!
    
    public func showMyProfile(memberId: Int) {
        memberProfileWireframe.presentMemberProfileInterfaceFromRevealViewController(memberId, revealViewController: menuViewController.revealViewController())
    }
    
}
