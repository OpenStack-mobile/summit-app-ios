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

public class SchedulePresenter: NSObject, ISchedulePresenter {
    var summitTimeZoneOffsetLocalTimeZone: Int!
    var session: ISession!
    var dayEvents: [ScheduleItemDTO]!
    var scheduleFilter: ScheduleFilter!
    var internalInteractor: IScheduleInteractor!
    var internalViewController: IScheduleViewController!
    var internalWireframe: IScheduleWireframe!
    
    public override init() {
        super.init()
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
    }
    
    public func viewLoad() {
        viewLoad(internalInteractor, viewController: internalViewController)
    }
    
    public func reloadSchedule() {
        reloadSchedule(internalInteractor, viewController: internalViewController)
    }
    
    public func buildScheduleCell(cell: IScheduleTableViewCell, index: Int){
        buildScheduleCell(cell, index: index, interactor: internalInteractor)
    }
    
    public func getDayEventsCount() -> Int {
        return dayEvents.count
    }
    
    public func showEventDetail(index: Int) {
        let event = dayEvents[index]
        internalWireframe.showEventDetail(event.id)
    }
    
    public func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        toggleScheduledStatus(index, cell: cell, interactor: internalInteractor, viewController: internalViewController)
    }
    
    func loggedIn(notification: NSNotification) {
        loggedIn(notification, viewController: internalViewController)
    }
    
    func loggedOut(notification: NSNotification) {
        loggedOut(notification, viewController: internalViewController)
    }
    
    func viewLoad(interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        internalViewController.showActivityIndicator()
        
        interactor.getActiveSummit() { summit, error in
            defer { viewController.hideActivityIndicator() }

            if (error != nil) {
                viewController.showErrorMessage(error!)
                return
            }
            
            let offsetLocalTimeZone = -NSTimeZone.localTimeZone().secondsFromGMT
            self.summitTimeZoneOffsetLocalTimeZone = NSTimeZone(name: summit!.timeZone)!.secondsFromGMT + offsetLocalTimeZone
            viewController.startDate = summit!.startDate.mt_dateSecondsAfter(offsetLocalTimeZone)
            viewController.endDate = summit!.endDate.mt_dateSecondsAfter(offsetLocalTimeZone).mt_dateDaysAfter(1)
            viewController.selectedDate = viewController.startDate
        }
    }
    
    func reloadSchedule(interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        let startDate = viewController.selectedDate.mt_dateSecondsAfter(-summitTimeZoneOffsetLocalTimeZone)
        let endDate = viewController.selectedDate.mt_dateDaysAfter(1).mt_dateSecondsAfter(-summitTimeZoneOffsetLocalTimeZone)
        
        dayEvents = interactor.getScheduleEvents(
            startDate,
            endDate: endDate,
            eventTypes: scheduleFilter.selections[FilterSectionTypes.EventType],
            summitTypes: scheduleFilter.selections[FilterSectionTypes.SummitType],
            tracks: scheduleFilter.selections[FilterSectionTypes.Track]
        )
        viewController.reloadSchedule()
    }
    
    public func buildScheduleCell(cell: IScheduleTableViewCell, index: Int, interactor: IScheduleInteractor) {
        let event = dayEvents[index]
        cell.eventTitle = event.name
        cell.timeAndPlace = event.date
        cell.scheduledButtonText = interactor.isEventScheduledByLoggedUser(event.id) ? "remove" : "schedule"
    }
    
    public func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell, interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        let event = dayEvents[index]
        let isScheduled = interactor.isEventScheduledByLoggedUser(event.id)
        if (isScheduled) {
            removeEventFromSchedule(event, cell: cell, interactor: interactor, viewController: viewController)
        }
        else {
            addEventToSchedule(event, cell: cell, interactor: interactor, viewController: viewController)
        }
    }
    
    func addEventToSchedule(event: ScheduleItemDTO, cell: IScheduleTableViewCell, interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        cell.scheduledButtonText = "remove"
        interactor.addEventToLoggedInMemberSchedule(event.id) { error in
            if (error != nil) {
                viewController.showErrorMessage(error!)
            }
        }
    }
    
    func removeEventFromSchedule(event: ScheduleItemDTO, cell: IScheduleTableViewCell, interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        cell.scheduledButtonText = "schedule"
        interactor.removeEventFromLoggedInMemberSchedule(event.id) { error in
            if (error != nil) {
                viewController.showErrorMessage(error!)
            }
        }
    }
    
    func loggedIn(notification: NSNotification, viewController: IScheduleViewController) {
        viewController.reloadSchedule()
    }
    
    func loggedOut(notification: NSNotification, viewController: IScheduleViewController) {
        viewController.reloadSchedule()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
