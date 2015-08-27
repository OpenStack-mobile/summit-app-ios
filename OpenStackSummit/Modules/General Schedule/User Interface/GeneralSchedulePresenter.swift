//
//  GeneralSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import MTDates

class GeneralSchedulePresenter: NSObject {
    
    weak var viewController : GeneralScheduleViewController?
    var interactor : GeneralScheduleInteractor?
    var generalScheduleWireframe : GeneralScheduleWireframe?
    
    func filterEvents(events: [SummitEvent], byDate date: NSDate) -> [SummitEvent] {
        return events.filter { (event) -> Bool in
            event.start.mt_isWithinSameDay(date)
        }
    }
    
    func reloadScheduleAsync() {
        self.interactor?.getScheduleEventsAsync()
    }
    
    func reloadSchedule(events: [SummitEvent]) {
        var startDate = NSDate.distantFuture()
        var endDate = NSDate.distantPast()
        
        for event in events {
            if event.start.mt_isBefore(startDate) {
                startDate = event.start.mt_startOfCurrentDay()
            }
            if event.end.mt_isAfter(endDate) {
                endDate = event.end.mt_startOfCurrentDay().mt_dateDaysAfter(1)
            }
        }
        
        self.viewController?.events = events
        self.viewController?.dayEvents = filterEvents(events, byDate: startDate)
        
        self.viewController?.dayPicker.startDate = startDate
        self.viewController?.dayPicker.endDate = endDate
        self.viewController?.dayPicker.firstActiveDate = startDate
        self.viewController?.dayPicker.lastActiveDate = endDate
        
        self.viewController?.dayPicker.selectDate(startDate, animated: false)
    }
    
    func reloadSchedule(byDate date: NSDate) {
        self.viewController?.dayEvents = filterEvents((self.viewController?.events)!, byDate: date)
        self.viewController?.reloadSchedule()
    }
    
    func showEventDetail(eventId: Int) {
        self.generalScheduleWireframe?.showEventDetail(eventId)
    }
}
