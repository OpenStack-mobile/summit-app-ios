//
//  VenueDetailWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueDetailWireframe {
    func presentVenueDetailView(venueId: Int, viewController: UINavigationController)
    func presentVenueLocationDetailView(venueId: Int, viewController: UINavigationController)
}

public class VenueDetailWireframe: NSObject, IVenueDetailWireframe {
    var venueDetailViewController: VenueDetailViewController!
    var venueLocationDetailViewController: VenueLocationDetailViewController!
    
    public func presentVenueDetailView(venueId: Int, viewController: UINavigationController) {
        let newViewController = venueDetailViewController!
        let _ = venueDetailViewController.view!
        venueDetailViewController.presenter.viewLoad(venueId)
        viewController.pushViewController(newViewController, animated: true)
    }
    
    public func presentVenueLocationDetailView(venueId: Int, viewController: UINavigationController) {
        let newViewController = venueLocationDetailViewController!
        let _ = venueLocationDetailViewController.view!
        venueLocationDetailViewController.presenter.viewLoad(venueId)
        viewController.pushViewController(newViewController, animated: true)
    }
}
