//
//  MyProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

@objc
public protocol IMyProfileWireframe {
    func showMemberProfile(memberId: Int, revealViewController: SWRevealViewController)
}

class MyProfileWireframe: NSObject, IMyProfileWireframe {
    
    var navigationController: UINavigationController!
    var myProfileViewController: MyProfileViewController!

    func showMemberProfile(memberId: Int, revealViewController: SWRevealViewController) {
        myProfileViewController.presenter.viewLoad(memberId)
        navigationController.setViewControllers([myProfileViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
}
