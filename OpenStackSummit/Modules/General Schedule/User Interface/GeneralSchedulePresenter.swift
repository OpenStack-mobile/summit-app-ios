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
    func reloadSchedule(events: [SummitEvent])
    func reloadSchedule(byDate date: NSDate)
    func showEventDetail(eventId: Int)
}

public class GeneralSchedulePresenter: NSObject {
    
    weak var viewController : GeneralScheduleViewController!
    var interactor : IGeneralScheduleInteractor!
    var generalScheduleWireframe : IGeneralScheduleWireframe!
    
    public func reloadSchedule() {
        self.interactor.getScheduleEvents() { events, error in
            self.reloadSchedule(events!)
        }
    }
    
    public func reloadSchedule(events: [SummitEvent]) {
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
        
        self.viewController.events = events
        self.viewController.dayEvents = events.filter(byDate: startDate)
        
        self.viewController.dayPicker.startDate = startDate
        self.viewController.dayPicker.endDate = endDate
        self.viewController.dayPicker.firstActiveDate = startDate
        self.viewController.dayPicker.lastActiveDate = endDate
        
        self.viewController.dayPicker.selectDate(startDate, animated: false)
    }
    
    func reloadSchedule(byDate date: NSDate) {
        self.viewController.dayEvents = (self.viewController?.events)!.filter(byDate: date)
        self.viewController.reloadSchedule()
    }
    
    func showEventDetail(eventId: Int) {
        self.generalScheduleWireframe.showEventDetail(eventId)
    }
}
