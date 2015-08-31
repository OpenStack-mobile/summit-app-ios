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
    func showEventDetail() -> SummitEvent
    var eventId: Int { get set }
}

public class EventDetailPresenter: NSObject {
    weak var viewController : EventDetailViewController!
    var interactor : IEventDetailInteractor!
    var eventId = 0
    
    public func showEventDetail() -> SummitEvent {
        return self.interactor.getEventDetail(eventId)
    }
    
    public func addEventToMyScheduleAsync() {
        interactor.addEventToMyScheduleAsync(eventId) { (event, error) in
            self.addEventToMyScheduleCallback(event, error: error)
        }
    }
    
    private func addEventToMyScheduleCallback(event: SummitEvent?, error: NSError?) {
        if (error == nil) {
            viewController.didFinishAddingEventToMySchedule(event!)
        }
        else {
            viewController.handleError(error!)
        }
    }
}
