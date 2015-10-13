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
    
    func leaveFeedback()
    func addEventToMySchedule()
}

public class EventDetailPresenter: NSObject {
    weak var viewController : IEventDetailViewController!
    var interactor : IEventDetailInteractor!
    var wireframe: IEventDetailWireframe!
    var eventId = 0
    
    public func prepareEventDetail(eventId: Int) {
        self.eventId = eventId
        let event = self.interactor.getEventDetail(eventId)
       
        viewController.eventTitle = event.title
        viewController.eventDescription = event.eventDescription
        viewController.location = event.location
        viewController.date = event.date
        viewController.allowFeedback = event.allowFeedback
    }
    
    public func addEventToMySchedule() {
        interactor.addEventToMySchedule(eventId) { (event, error) in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
            self.viewController.didAddEventToMySchedule(event!)
        }
    }
    
    public func leaveFeedback() {
        wireframe.showFeedbackEdit(eventId)
    }    
}
