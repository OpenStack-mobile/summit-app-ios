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
    func showEvents()
}

class MemberOrderConfirmWireframe: NSObject, IMemberOrderConfirmWireframe {
    var navigationController: NavigationController!
    var revealViewController: SWRevealViewController!
    var memberOrderConfirmViewController: MemberOrderConfirmViewController!
    var eventsWireframe: IEventsWireframe!
    
    func pushMemberOrderConfirmView() {
        navigationController.setViewControllers([memberOrderConfirmViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    func showEvents() {
        eventsWireframe.pushEventsView()
    }
    
}
