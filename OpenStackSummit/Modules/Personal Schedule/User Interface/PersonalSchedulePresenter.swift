//
//  PersonalSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IPersonalSchedulePresenter: ISchedulePresenter {
    func viewLoad(attendeeId: Int)
}

public class PersonalSchedulePresenter: SchedulePresenter {
    var attendeeId = 0
    var isLoaded = false
    
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
    
    public func viewLoad(attendeeId: Int) {
        self.attendeeId = attendeeId
        viewLoad()
    }
    
    public override func reloadSchedule() {
        let startDate = viewController.selectedDate.mt_dateSecondsAfter(-summitTimeZoneOffsetLocalTimeZone)
        let endDate = viewController.selectedDate.mt_dateDaysAfter(1).mt_dateSecondsAfter(-summitTimeZoneOffsetLocalTimeZone)
        
        dayEvents = interactor.getLoggedInMemberScheduledEventsFrom(startDate, to: endDate)
        viewController.reloadSchedule()
    }
    
    public override func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        toggleScheduledStatus(index, cell: cell, interactor: internalInteractor, viewController: internalViewController) { error in
            self.reloadSchedule()
        }
    }
}
