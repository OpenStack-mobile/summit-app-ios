//
//  VenuesPresenter.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 2/23/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenuesPresenter {
    func getChildViews() -> [UIViewController]
}

public class VenuesPresenter: NSObject, IVenuesPresenter {
    var venuesMapViewController: VenuesMapViewController!
    var venueListViewController: VenueListViewController!
    
    public func getChildViews() -> [UIViewController] {
        var childViewController: [UIViewController] = []
        
        childViewController.append(venuesMapViewController)
        childViewController.append(venueListViewController)
        
        return childViewController
    }
}
