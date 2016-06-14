//
//  VenuesMapPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/21/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol VenuesMapPresenterProtocol {
    
    func viewLoad()
    func showVenueDetail(venueId: Int)
}

public final class VenuesMapPresenter: VenuesMapPresenterProtocol {
    
    var interactor = VenuesMapInteractor()
    var wireframe = VenueListWireframe()
    var viewController: VenuesMapViewController!
    var venueList = [VenueListItem]()
    
    public func viewLoad() {
        venueList = interactor.getInternalVenuesWithCoordinates()
        viewController.addMarkers(venueList)
    }
    
    public func showVenueDetail(venueId: Int) {
        wireframe.showVenueDetail(venueId)
    }
}
