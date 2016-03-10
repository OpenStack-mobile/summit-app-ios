//
//  VenuesMapPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/21/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenuesMapPresenter {
    func viewLoad()
    func showVenueDetail(venueId: Int)
}

public class VenuesMapPresenter: NSObject {
    var interactor: IVenuesMapInteractor!
    var wireframe: IVenueListWireframe!
    var viewController: IVenuesMapViewController!
    var venueList: [VenueListItemDTO]!
    
    public func viewLoad() {
        venueList = interactor.getInternalVenuesWithCoordinates()
        viewController.addMarkers(venueList)
    }
    
    public func showVenueDetail(venueId: Int) {
        wireframe.showVenueDetail(venueId)
    }
}
