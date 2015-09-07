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
    func showVenueDetail()
    func showVenueRoomDetail(venueRoomId: Int)
    
    var venueId: Int { get set }
}

public class VenueDetailPresenter: NSObject, IVenueDetailPresenter {
    public var venueId = 0
    var interactor: IVenueDetailInteractor!
    var viewController: IVenueDetailViewController!
    var venueDetailWireframe: IVenueDetailWireframe!
    
    public func showVenueDetail() {
        
    }
    
    public func showVenueRoomDetail(venueRoomId: Int) {
        venueDetailWireframe.showVenueRoomDetail(venueRoomId)
    }
}
