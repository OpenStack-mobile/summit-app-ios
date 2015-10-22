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
    func getVenueRoomsCount() -> Int
    func buildVenueRoomCell(cell: IVenueListTableViewCell, index: Int)
}

public class VenueDetailPresenter: NSObject, IVenueDetailPresenter {
    var venueId = 0
    var interactor: IVenueDetailInteractor!
    weak var viewController: IVenueDetailViewController!
    var wireframe: IVenueDetailWireframe!
    var venue: VenueDTO!
    
    public func viewLoad(venueId: Int) {
        venue = interactor.getVenue(venueId)
        viewController.name = venue.name
        viewController.address = venue.address
        viewController.addMarker(venue)
        viewController.reloadRoomsData()
    }
    
    public func showVenueRoomDetail(index: Int) {
        let venueRoom = venue.rooms[index]
        wireframe.showVenueRoomDetail(venueRoom.id)
    }
    
    public func getVenueRoomsCount() -> Int {
        return venue.rooms.count
    }
    
    public func buildVenueRoomCell(cell: IVenueListTableViewCell, index: Int) {
        let venueRoom = venue.rooms[index]
        cell.name = venueRoom.name
    }
    
}
