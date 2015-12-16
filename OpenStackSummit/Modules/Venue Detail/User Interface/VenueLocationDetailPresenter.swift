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
    var venueRoomId = 0
    var interactor: IVenueDetailInteractor!
    var viewController: IVenueLocationDetailViewController!
    var wireframe: IVenueDetailWireframe!
    
    public func viewLoad(venueId: Int) {
        let venue = interactor.getVenue(venueId)
        viewController.name = venue.name
        viewController.addMarker(venue)
    }
}
