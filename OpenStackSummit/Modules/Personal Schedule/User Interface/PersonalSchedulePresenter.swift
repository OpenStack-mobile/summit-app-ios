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
    
    var interactor : IPersonalScheduleInteractor! {
        get {
            return internalInteractor as! IPersonalScheduleInteractor
        }
        set {
            internalInteractor = newValue
        }
    }
    
    var wireframe : IScheduleWireframe! {
        get {
            return internalWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [ScheduleItemDTO] {
        let events = (interactor as! IPersonalScheduleInteractor).getLoggedInMemberScheduledEventsFrom(startDate, to: endDate)
        return events
    }
    
    public override func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        let event = dayEvents[index]
        toggleScheduledStatusForEvent(event, scheduleableView: cell, interactor: internalInteractor) { error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
            self.reloadSchedule()
        }
    }
}
