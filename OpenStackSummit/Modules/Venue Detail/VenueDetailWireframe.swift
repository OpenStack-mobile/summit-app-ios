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
    func showVenueRoomDetail(venueRoomId: Int)
}

public class VenueDetailWireframe: NSObject, IVenueDetailWireframe {
    var venueDetailViewController: VenueDetailViewController!
    var venueRoomDetailWireframe: IVenueRoomDetailWireframe!
    
    public func presentVenueDetailView(venueId: Int, viewController: UINavigationController) {
        let newViewController = venueDetailViewController!
        venueDetailViewController.presenter.venueId = venueId
        viewController.pushViewController(newViewController, animated: true)
    }
    
    public func showVenueRoomDetail(venueRoomId: Int) {
        venueRoomDetailWireframe.presentVenueRoomDetailView(venueRoomId, viewController: venueDetailViewController.navigationController!)
    }
}
