//
//  MemberOrderConfirmWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

@objc
protocol IMemberOrderConfirmWireframe {
    func pushMemberOrderConfirmView()
}

class MemberOrderConfirmWireframe: NSObject, IMemberOrderConfirmWireframe {
    var navigationController: NavigationController!
    var revealViewController: SWRevealViewController!
    var memberOrderConfirmViewController: MemberOrderConfirmViewController!
    
    func pushMemberOrderConfirmView() {
        navigationController.setViewControllers([memberOrderConfirmViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
}
