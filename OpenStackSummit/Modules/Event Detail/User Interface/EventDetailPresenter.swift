//
//  EventDetailPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventDetailPresenter {
    func prepareEventDetail(eventId: Int)
    var eventId: Int { get set }
}

public class EventDetailPresenter: NSObject {
    weak var viewController : IEventDetailViewController!
    var interactor : IEventDetailInteractor!
    var eventId = 0
    
    public func prepareEventDetail(eventId: Int) {
        self.eventId = eventId
        let event = self.interactor.getEventDetail(eventId)
        viewController.showEventDetail(event)
    }
    
    public func addEventToMySchedule() {
        interactor.addEventToMySchedule(eventId) { (event, error) in
            self.addEventToMyScheduleCallback(event, error: error)
        }
    }
    
    private func addEventToMyScheduleCallback(event: EventDetailDTO?, error: NSError?) {
        if (error != nil) {
            viewController.handleError(error!)
        }
        viewController.didAddEventToMySchedule(event!)
    }
}
