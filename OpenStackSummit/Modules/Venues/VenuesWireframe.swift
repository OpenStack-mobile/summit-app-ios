//
//  VenuesWireframe.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 2/23/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

@objc
public protocol IVenuesWireframe {
    func pushVenuesView()
}

public class VenuesWireframe: NSObject, IVenuesWireframe {
    var navigationController: NavigationController!
    var revealViewController: SWRevealViewController!
    var venuesViewController: VenuesViewController!
    
    public func pushVenuesView() {
        navigationController.setViewControllers([venuesViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
}
