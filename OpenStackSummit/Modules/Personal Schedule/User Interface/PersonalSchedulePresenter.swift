//
//  PersonalSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class PersonalSchedulePresenter: SchedulePresenter {
    
    weak var viewController : IScheduleViewController! {
        get {
            return internalViewController
        }
        set {
            internalViewController = newValue
        }
    }
    
    var interactor : PersonalScheduleInteractorProtocol! {
        get {
            return internalInteractor as! PersonalScheduleInteractorProtocol
        }
        set {
            internalInteractor = newValue
        }
    }
    
    var wireframe : ScheduleWireframe! {
        get {
            return internalWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    override func getScheduleAvailableDatesFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: ScheduleInteractorProtocol) -> [NSDate] {
        let availableDates = (interactor as! PersonalScheduleInteractorProtocol).getLoggedInMemberScheduledEventsDatesFrom(startDate, to: endDate)
        return availableDates
    }
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: ScheduleInteractorProtocol) -> [ScheduleItem] {
        let events = (interactor as! PersonalScheduleInteractorProtocol).getLoggedInMemberScheduledEventsFrom(startDate, to: endDate)
        return events
    }
    
    public override func toggleScheduledStatus(index: Int, cell: ScheduleTableViewCellProtocol) {
        let event = dayEvents[index]
        toggleScheduledStatusForEvent(event, scheduleableView: cell, interactor: internalInteractor) { error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
            self.reloadSchedule()
        }
    }
}
