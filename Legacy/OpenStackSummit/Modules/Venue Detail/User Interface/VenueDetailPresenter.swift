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
    func showVenueLocationDetail()
}

public class VenueDetailPresenter: NSObject, IVenueDetailPresenter {
    var venueId = 0
    var interactor: IVenueDetailInteractor!
    var viewController: IVenueDetailViewController!
    var wireframe: IVenueDetailWireframe!
    var venue: VenueDTO!
    
    public func viewLoad(venueId: Int) {
        self.venueId = venueId
        venue = interactor.getVenue(venueId)
        viewController.name = venue.name
        viewController.location = venue.address
        
        
        viewController.toggleImagesGallery(venue.images.count > 0)
        if venue.images.count > 0 {
            viewController.images = venue.images
        }
        
        viewController.toggleMapNavigation(venue.maps.count > 0)
        viewController.toggleMapsGallery(venue.maps.count > 0)
        viewController.toggleMap(venue.maps.count == 0 && isVenueGeoLocated(venue))
        
        if venue.maps.count > 0 {
            viewController.maps = venue.maps
        }
        else if isVenueGeoLocated(venue) {
            viewController.addMarker(venue)
        }
    }
    
    private func isVenueGeoLocated(venue: VenueDTO) -> Bool {
        return venue.lat != nil && venue.long != nil
    }
    
    public func showVenueLocationDetail() {
        wireframe.presentVenueLocationDetailView(venueId, viewController: viewController.navigationController!)
    }
}
