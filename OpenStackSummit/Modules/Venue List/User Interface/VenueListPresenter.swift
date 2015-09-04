//
//  VenueListPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueListPresenter : IPresenter{
    
}


public class VenueListPresenter: NSObject, IVenueListPresenter {
    var venueListWireframe: IVenueListWireframe!
    var viewController: IVenueListViewController!
    var venueListInteractor: IVenueListInteractor!
    
    public func showVenueList() {
        
    }
}
