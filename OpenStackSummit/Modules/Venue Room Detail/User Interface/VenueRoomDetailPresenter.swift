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
    func showVenueRoomDetail()
    var venueRoomId: Int { get set }
}

public class VenueRoomDetailPresenter: NSObject, IVenueRoomDetailPresenter {
    public var venueRoomId = 0
    var interactor: IVenueRoomDetailInteractor!
    var viewController: IVenueRoomDetailViewController!
    var wireframe: IVenueRoomDetailWireframe!
    var venueRoomDetailDTOAssembler: IVenueRoomDetailDTOAssembler!
    
    public func showVenueRoomDetail() {
        let venueRoom = interactor.getVenueRoom(venueRoomId)
        let venueRoomDetailDTO = venueRoomDetailDTOAssembler.createDTO(venueRoom)
        viewController.showVenueRoomDetail(venueRoomDetailDTO)
    }
}
