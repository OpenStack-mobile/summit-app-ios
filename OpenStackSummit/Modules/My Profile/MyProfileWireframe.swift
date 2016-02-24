//
//  MyProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

@objc
public protocol IMyProfileWireframe {
    func pushMyProfileView()
}

public class MyProfileWireframe: NSObject, IMyProfileWireframe {
    var navigationController: NavigationController!
    var revealViewController: SWRevealViewController!
    var myProfileViewController: MyProfileViewController!
    
    public func pushMyProfileView() {
        navigationController.setViewControllers([myProfileViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
}