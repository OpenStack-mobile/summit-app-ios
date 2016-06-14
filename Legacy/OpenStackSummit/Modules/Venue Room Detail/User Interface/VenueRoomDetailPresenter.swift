//
//  VenueRoomDetailPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueRoomDetailPresenter {    
    func viewLoad(venueRoomId: Int)
}

public class VenueRoomDetailPresenter: NSObject, IVenueRoomDetailPresenter {
    var venueRoomId = 0
    var interactor: IVenueRoomDetailInteractor!
    var viewController: IVenueRoomDetailViewController!
    var wireframe: IVenueRoomDetailWireframe!
    
    public func viewLoad(venueRoomId: Int) {
        let venueRoom = interactor.getVenueRoom(venueRoomId)
        viewController.name = venueRoom!.name
        viewController.capacity = venueRoom!.capacity
        //viewController.picUrl = venueRoom.pictu
    }
}
