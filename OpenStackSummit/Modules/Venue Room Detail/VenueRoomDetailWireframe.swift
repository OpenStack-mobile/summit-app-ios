//
//  VenueRoomWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueRoomDetailWireframe {
    func presentVenueRoomDetailView(venueRoomId: Int, viewController: UINavigationController)
}

public class VenueRoomDetailWireframe: NSObject, IVenueRoomDetailWireframe {
    var venueRoomDetailViewController : VenueRoomDetailViewController!
    
    public func presentVenueRoomDetailView(venueRoomId: Int, viewController: UINavigationController) {
        let newViewController = venueRoomDetailViewController!
        venueRoomDetailViewController.presenter.venueRoomId = venueRoomId
        viewController.pushViewController(newViewController, animated: true)
    }
}
