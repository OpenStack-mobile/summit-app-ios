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
    func showVenueDetail(venueId: Int)
}


public class VenueListWireframe: NSObject, IVenueListWireframe {
    var venueDetailWireframe : IVenueDetailWireframe!
    var venueListViewController: VenueListViewController!
    
    public func showVenueDetail(venueId: Int) {
        venueDetailWireframe.presentVenueDetailView(venueId, viewController: venueListViewController.navigationController!)
    }
}
