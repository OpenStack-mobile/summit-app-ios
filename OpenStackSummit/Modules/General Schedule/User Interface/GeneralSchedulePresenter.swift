//
//  GeneralSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import MTDates

extension Array where Element: SummitEvent {
    func filter(byDate date: NSDate) -> [SummitEvent] {
        return self.filter { (event) -> Bool in
            event.start.mt_isWithinSameDay(date)
        }
    }
}

@objc
public protocol IGeneralSchedulePresenter {
    func reloadSchedule()
    func showEventDetail(eventId: Int)
    func viewLoad()
}

public class GeneralSchedulePresenter: NSObject {
    
    weak var viewController : IGeneralScheduleViewController!
    var interactor : IGeneralScheduleInteractor!
    var generalScheduleWireframe : IGeneralScheduleWireframe!
    
    public func viewLoad() {
        
        interactor.getActiveSummit() { summit, error in
            if (error == nil) {
                self.viewController.startDate = summit!.startDate.mt_startOfCurrentDay()
                self.viewController.endDate = summit!.endDate.mt_startOfCurrentDay()
                self.viewController.selectedDate = self.viewController.startDate

                self.reloadSchedule()
            }
            else {
                self.viewController.handleError(error!)
            }
        }
    }
    
    public func reloadSchedule() {
        
        let events = self.interactor.getScheduleEventsForDate(viewController.selectedDate.mt_startOfCurrentDay(), endDate: viewController.selectedDate.mt_startOfCurrentDay().mt_startOfCurrentDay().mt_dateDaysAfter(1))
        self.viewController.dayEvents = events
        self.viewController.reloadSchedule()
    }
    
    func showEventDetail(eventId: Int) {
        self.generalScheduleWireframe.showEventDetail(eventId)
    }
}
