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
        let event = dayEvents[index]
        cell.eventTitle = event.name
        cell.eventType = event.eventType
        cell.time = event.date
        cell.place = event.location
        cell.scheduledStatus = internalInteractor.isEventScheduledByLoggedMember(event.id) ? ScheduledStatus.Scheduled : ScheduledStatus.NotScheduled
        cell.isScheduledStatusVisible = internalInteractor.isMemberLoggedIn()
    }
    
    public func getDayEventsCount() -> Int {
        return dayEvents.count
    }
    
    public func showEventDetail(index: Int) {
        let event = dayEvents[index]
        internalWireframe.showEventDetail(event.id)
    }
    
    public func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        toggleScheduledStatus(index, cell: cell, interactor: internalInteractor, viewController: internalViewController, completionBlock: nil)
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

                if (error != nil) {
                    viewController.showErrorMessage(error!)
                    return
                }
                
                let offsetLocalTimeZone = -NSTimeZone.localTimeZone().secondsFromGMT
                self.summitTimeZoneOffsetLocalTimeZone = NSTimeZone(name: summit!.timeZone)!.secondsFromGMT + offsetLocalTimeZone
                viewController.startDate = summit!.startDate.mt_dateSecondsAfter(offsetLocalTimeZone)
                viewController.endDate = summit!.endDate.mt_dateSecondsAfter(offsetLocalTimeZone).mt_dateDaysAfter(1)
                viewController.selectedDate = viewController.startDate
            })
        }
    }
    
    func reloadSchedule(interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        dispatch_async(dispatch_get_main_queue(),{
            let startDate = viewController.selectedDate.mt_dateSecondsAfter(-self.summitTimeZoneOffsetLocalTimeZone)
            let endDate = viewController.selectedDate.mt_dateDaysAfter(1).mt_dateSecondsAfter(-self.summitTimeZoneOffsetLocalTimeZone)
            
            let eventTypeSelections: [Int]? = self.scheduleFilter.areAllSelectedForType(FilterSectionType.EventType) ? nil : self.scheduleFilter.selections[FilterSectionType.EventType]
            let summitTypeSelections = self.scheduleFilter.areAllSelectedForType(FilterSectionType.SummitType) ? nil : self.scheduleFilter.selections[FilterSectionType.SummitType]
            let trackSelections = self.scheduleFilter.areAllSelectedForType(FilterSectionType.Track) ? nil : self.scheduleFilter.selections[FilterSectionType.Track]
            
            self.dayEvents = interactor.getScheduleEvents(
                startDate,
                endDate: endDate,
                eventTypes: eventTypeSelections,
                summitTypes: summitTypeSelections,
                tracks: trackSelections
            )
            viewController.reloadSchedule()
        })
    }
    
    public func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell, interactor: IScheduleInteractor, viewController: IScheduleViewController, completionBlock: ((NSError?) -> Void)?) {
        let event = dayEvents[index]
        let isScheduled = interactor.isEventScheduledByLoggedMember(event.id)
        if (isScheduled) {
            removeEventFromSchedule(event, cell: cell, interactor: interactor, viewController: viewController, completionBlock: completionBlock)
        }
        else {
            addEventToSchedule(event, cell: cell, interactor: interactor, viewController: viewController, completionBlock: completionBlock)
        }
    }
    
    func addEventToSchedule(event: ScheduleItemDTO, cell: IScheduleTableViewCell, interactor: IScheduleInteractor, viewController: IScheduleViewController, completionBlock: ((NSError?) -> Void)?) {
        interactor.addEventToLoggedInMemberSchedule(event.id) { error in
            dispatch_async(dispatch_get_main_queue(),{
                if (error != nil) {
                    viewController.showErrorMessage(error!)
                }

                cell.scheduledStatus = .Scheduled
                if (completionBlock != nil) {
                    completionBlock!(error)
                }
            })
        }
    }
    
    func removeEventFromSchedule(event: ScheduleItemDTO, cell: IScheduleTableViewCell, interactor: IScheduleInteractor, viewController: IScheduleViewController, completionBlock: ((NSError?) -> Void)?) {
        interactor.removeEventFromLoggedInMemberSchedule(event.id) { error in
            dispatch_async(dispatch_get_main_queue(),{
                if (error != nil) {
                    viewController.showErrorMessage(error!)
                }
                cell.scheduledStatus = .NotScheduled
                if (completionBlock != nil) {
                    completionBlock!(error)
                }
            })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
