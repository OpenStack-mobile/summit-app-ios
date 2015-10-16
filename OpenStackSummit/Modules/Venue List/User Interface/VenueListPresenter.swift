//
//  VenueListPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueListPresenter {
    func viewLoad()
    func getVenuesCount() -> Int
    func buildVenueCell(cell: IVenueListTableViewCell, index: Int)
    func showVenueDetail(venueId: Int)
}

public class VenueListPresenter: NSObject, IVenueListPresenter {
    var wireframe: IVenueListWireframe!
    var viewController: IVenueListViewController!
    var interactor: IVenueListInteractor!
    var venueList: [VenueListItemDTO]!
    
    public func viewLoad() {
        venueList = interactor.getVenues()
        viewController.releoadList()
    }
    
    public func getVenuesCount() -> Int {
        return venueList.count
    }
    
    public func buildVenueCell(cell: IVenueListTableViewCell, index: Int){
        let venue = venueList[index]
        cell.name = venue.name
        cell.address = venue.address
    }
    
    public func showVenueDetail(venueId: Int) {
        wireframe.showVenueDetail(venueId)
    }
}
