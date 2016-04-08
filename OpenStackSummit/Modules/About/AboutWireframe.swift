//
//  AboutWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

@objc
public protocol IAboutWireframe {
    func pushAboutView()
}


public class AboutWireframe: NSObject, IAboutWireframe {
    var navigationController: NavigationController!
    var revealViewController: SWRevealViewController!
    var aboutViewController: AboutViewController!
    
    public func pushAboutView() {
        navigationController.setViewControllers([aboutViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
}
