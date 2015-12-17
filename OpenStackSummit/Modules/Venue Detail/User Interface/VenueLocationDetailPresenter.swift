//
//  VenueLocationDetailPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueLocationDetailPresenter {
    func viewLoad(venueId: Int)
}

public class VenueLocationDetailPresenter: NSObject, IVenueLocationDetailPresenter {
    var interactor: IVenueDetailInteractor!
    var viewController: IVenueLocationDetailViewController!
    
    public func viewLoad(venueId: Int) {
        let venue = interactor.getVenue(venueId)
        viewController.addMarker(venue)
    }
}
