//
//  VenueListWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueListWireframe {
    func presentVenueListView(viewController: UINavigationController)
}


public class VenueListWireframe: NSObject, IVenueListWireframe {
    
    var venueListViewController: VenueListViewController!
    
    public func presentVenueListView(viewController: UINavigationController) {
        let newViewController = venueListViewController!
        viewController.pushViewController(newViewController, animated: true)
    }
}
