//
//  SchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISchedulePresenter {
    func reloadSchedule()
    func showEventDetail(index: Int)
    func viewLoad()
    func buildScheduleCell(cell: IScheduleTableViewCell, index: Int)
    func getDayEventsCount() -> Int
    func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell)
}

public class SchedulePresenter: ScheduleablePresenter, ISchedulePresenter {
    var summitTimeZoneOffset: Int!
    var session: ISession!
    var dayEvents: [ScheduleItemDTO]!
    var scheduleFilter: ScheduleFilter!
    var internalInteractor: IScheduleInteractor!
    var internalViewController: IScheduleViewController!
    var internalWireframe: IScheduleWireframe!
    var useFilter = false
    var selectedDate: NSDate?
    
    public override init() {
        super.init()
    }
    
    public func viewLoad() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "loggedIn:",
            name: Constants.Notifications.LoggedInNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "loggedOut:",
            name: Constants.Notifications.LoggedOutNotification,
            object: nil)

        viewLoad(internalInteractor, viewController: internalViewController)
    }
    
    public func reloadSchedule() {
        reloadSchedule(internalInteractor, viewController: internalViewController)
    }
    
    public func buildScheduleCell(cell: IScheduleTableViewCell, index: Int){
        let event = dayEvents[index]
        cell.eventTitle = event.name
        cell.eventType = event.eventType
        cell.time = event.time
        cell.location = event.location
        cell.sponsors = event.sponsors
        cell.track = event.track
        cell.scheduled = internalInteractor.isEventScheduledByLoggedMember(event.id)
        cell.isScheduledStatusVisible = internalInteractor.isMemberLoggedIn()
        cell.summitTypeColor = event.summitTypeColor != "" ? UIColor(hexaString: event.summitTypeColor) : nil
    }
    
    public func getDayEventsCount() -> Int {
        return dayEvents.count
    }
    
    public func showEventDetail(index: Int) {
        let event = dayEvents[index]
        internalWireframe.showEventDetail(event.id)
    }
    
    public func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        let event = dayEvents[index]
        toggleScheduledStatusForEvent(event, scheduleableView: cell, interactor: internalInteractor) { error in
            if (error != nil) {
                self.internalViewController.showErrorMessage(error!)
            }
        }
    }
    
    func loggedIn(notification: NSNotification) {
        internalViewController.reloadSchedule()
    }
    
    func loggedOut(notification: NSNotification) {
        internalViewController.reloadSchedule()
    }
    
    func viewLoad(interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        internalViewController.showActivityIndicator()
        
        interactor.getActiveSummit() { summit, error in
            dispatch_async(dispatch_get_main_queue(),{
                defer { viewController.hideActivityIndicator() }

                self.internalInteractor.subscribeToPushChannelsUsingContextIfNotDoneAlready()

                if (error != nil) {
                    viewController.showErrorMessage(error!)
                    return
                }
                
                self.summitTimeZoneOffset = NSTimeZone(name: summit!.timeZone)!.secondsFromGMT
                viewController.startDate = summit!.startDate.mt_dateSecondsAfter(self.summitTimeZoneOffset).mt_startOfCurrentDay()
                viewController.endDate = summit!.endDate.mt_dateSecondsAfter(self.summitTimeZoneOffset).mt_dateDaysAfter(1)
                viewController.selectedDate = self.selectedDate != nil ? self.selectedDate : viewController.startDate
            })
        }
    }
    
    func reloadSchedule(interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        dispatch_async(dispatch_get_main_queue(),{
            self.selectedDate = viewController.selectedDate
            
            let offsetLocalTimeZone = NSTimeZone.localTimeZone().secondsFromGMT
            
            let startDate = viewController.selectedDate.mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
            let endDate = viewController.selectedDate.mt_endOfCurrentDay().mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
            
            self.dayEvents = self.getScheduledEventsFrom(startDate, to: endDate, withInteractor: interactor)
            
            viewController.reloadSchedule()
        })
    }
    
    func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [ScheduleItemDTO] {
        let eventTypeSelections = self.useFilter ? self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int] : nil
        let summitTypeSelections = self.useFilter ? self.scheduleFilter.selections[FilterSectionType.SummitType] as? [Int] : nil
        let trackSelections = self.useFilter ? self.scheduleFilter.selections[FilterSectionType.Track] as? [Int] : nil
        let tagSelections = self.useFilter ? self.scheduleFilter.selections[FilterSectionType.Tag] as? [String] : nil
        let levelSelections = self.useFilter ? self.scheduleFilter.selections[FilterSectionType.Level] as? [String] : nil
        
        let events = interactor.getScheduleEvents(
            startDate,
            endDate: endDate,
            eventTypes: eventTypeSelections,
            summitTypes: summitTypeSelections,
            tracks: trackSelections,
            tags: tagSelections,
            levels: levelSelections
        )
        
        return events
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
