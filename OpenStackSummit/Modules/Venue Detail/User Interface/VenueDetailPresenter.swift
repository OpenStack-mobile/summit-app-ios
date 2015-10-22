//
//  VenueDetailPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueDetailPresenter {
    func viewLoad(venueId: Int)
    func showVenueRoomDetail(venueRoomId: Int)
}

public class VenueDetailPresenter: NSObject, IVenueDetailPresenter {
    var venueId = 0
    var interactor: IVenueDetailInteractor!
    weak var viewController: IVenueDetailViewController!
    var wireframe: IVenueDetailWireframe!
    
    public func viewLoad(venueId: Int) {
        let venue = interactor.getVenue(venueId)
        viewController.name = venue.name
        viewController.address = venue.address
        viewController.addMarker(venue)
    }
    
    public func showVenueRoomDetail(venueRoomId: Int) {
        wireframe.showVenueRoomDetail(venueRoomId)
    }
}
