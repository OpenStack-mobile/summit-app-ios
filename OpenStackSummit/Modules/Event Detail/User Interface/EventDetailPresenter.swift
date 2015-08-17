//
//  EventDetailPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class EventDetailPresenter: NSObject {
    weak var viewController : EventDetailViewController?
    var interactor : EventDetailInteractor?
    var eventId: Int?
    
    func showEventDetailAsync() {
        self.interactor?.getEventDetailAsync(self.eventId!)
    }
    
    func showEventDetail(eventDetail: String) {
        viewController!.showEventDetail(eventDetail)
    }
}
