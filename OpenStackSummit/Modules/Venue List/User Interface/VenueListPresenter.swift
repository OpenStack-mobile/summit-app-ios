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
    func getInternalVenuesCount() -> Int
    func getExternalVenuesCount() -> Int
    func buildInternalVenueCell(cell: IInternalVenueListTableViewCell, index: Int)
    func buildExternalVenueCell(cell: IVenueListTableViewCell, index: Int)
    func showInternalVenueDetail(index: Int)
    func showExternalVenueDetail(index: Int)
}

public class VenueListPresenter: NSObject, IVenueListPresenter {
    var wireframe: IVenueListWireframe!
    var viewController: IVenueListViewController!
    var interactor: IVenueListInteractor!
    
    var internalVenueList: [VenueListItemDTO]!
    var externalVenueList: [VenueListItemDTO]!
    
    public func viewLoad() {
        internalVenueList = interactor.getInternalVenues()
        externalVenueList = interactor.getExternalVenues()
        viewController.reloadList()
    }
    
    public func getInternalVenuesCount() -> Int {
        return internalVenueList.count
    }
    
    public func getExternalVenuesCount() -> Int {
        return externalVenueList.count
    }
    
    public func buildInternalVenueCell(cell: IInternalVenueListTableViewCell, index: Int){
        let venue = internalVenueList[index]
        cell.name = venue.name
        cell.address = venue.address
        cell.backgroundImageUrl = venue.backgroundImageUrl
    }
    
    public func buildExternalVenueCell(cell: IVenueListTableViewCell, index: Int){
        let venue = externalVenueList[index]
        cell.name = venue.name
        cell.address = venue.address
    }
    
    public func showInternalVenueDetail(index: Int) {
        let venue = internalVenueList[index]
        wireframe.showVenueDetail(venue.id)
    }
    
    public func showExternalVenueDetail(index: Int) {
        let venue = externalVenueList[index]
        wireframe.showVenueDetail(venue.id)
    }
}
