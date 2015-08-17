//
//  EventDetailInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class EventDetailInteractor: NSObject {
    var delegate : EventDetailPresenter?
    
    func getEventDetailAsync(eventId: Int){
        if (delegate != nil) {
            let eventDetail = "testing event detail"
            delegate?.showEventDetail(eventDetail)
        }
    }
}
