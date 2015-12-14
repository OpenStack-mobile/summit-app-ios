//
//  MyProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController
import XLPagerTabStrip

@objc
public protocol IMyProfileWireframe {
    func presentMyProfileViewFromRevealViewController(revealViewController: SWRevealViewController)
}

public class MyProfileWireframe: NSObject, IMyProfileWireframe {
    var navigationController: UINavigationController!
    var myProfileViewController: MyProfileViewController!
    
    public func presentMyProfileViewFromRevealViewController(revealViewController: SWRevealViewController) {
        let _ = myProfileViewController.view! // this is only to force viewLoad to trigger
        navigationController.setViewControllers([myProfileViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
}