//
//  TrackSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackSchedulePresenter {
    func prepareTrackSchedule(trackId: Int)
    func reloadSchedule()
    func showEventDetail(index: Int)
    func viewLoad()
    func buildCell(cell: IScheduleTableViewCell, index: Int)
    func getDayEventsCount() -> Int
    func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell)
}

public class TrackSchedulePresenter: NSObject, ITrackSchedulePresenter {
    var trackId = 0
    weak var viewController : IScheduleViewController!
    var interactor : GeneralScheduleInteractor!
    var generalScheduleWireframe : IGeneralScheduleWireframe!
    var session: ISession!
    var summitTimeZoneOffsetLocalTimeZone: Int!
    var dayEvents: [ScheduleItemDTO]!
    
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
        interactor.getActiveSummit() { summit, error in
            
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            
            let offsetLocalTimeZone = -NSTimeZone.localTimeZone().secondsFromGMT
            self.summitTimeZoneOffsetLocalTimeZone = NSTimeZone(name: summit!.timeZone)!.secondsFromGMT + offsetLocalTimeZone
            self.viewController.startDate = summit!.startDate.mt_dateSecondsAfter(offsetLocalTimeZone)
            self.viewController.endDate = summit!.endDate.mt_dateSecondsAfter(offsetLocalTimeZone).mt_dateDaysAfter(1)
            self.viewController.selectedDate = self.viewController.startDate
        }
    }
    
    public func prepareTrackSchedule(trackId: Int) {
        self.trackId = trackId
    }
        
    public func reloadSchedule() {
        let filterSelections = session.get(Constants.SessionKeys.GeneralScheduleFilterSelections) as? Dictionary<FilterSectionTypes, [Int]>
        let startDate = viewController.selectedDate.mt_dateSecondsAfter(-summitTimeZoneOffsetLocalTimeZone)
        let endDate = viewController.selectedDate.mt_dateDaysAfter(1).mt_dateSecondsAfter(-summitTimeZoneOffsetLocalTimeZone)
        
        dayEvents = self.interactor.getScheduleEvents(
            startDate,
            endDate: endDate,
            eventTypes: filterSelections?[FilterSectionTypes.EventType],
            summitTypes: filterSelections?[FilterSectionTypes.SummitType]
        )
        self.viewController.reloadSchedule()
    }
    
    public func buildCell(cell: IScheduleTableViewCell, index: Int){
        let event = dayEvents[index]
        cell.eventTitle = event.name
        cell.timeAndPlace = event.date
        cell.scheduledButtonText = interactor.isEventScheduledByLoggedUser(event.id) ? "remove" : "schedule"
    }
    
    public func getDayEventsCount() -> Int {
        return dayEvents.count
    }
    
    public func showEventDetail(index: Int) {
        let event = dayEvents[index]
        self.generalScheduleWireframe.showEventDetail(event.id)
    }
    
    public func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        let event = dayEvents[index]
        let isScheduled = interactor.isEventScheduledByLoggedUser(event.id)
        if (isScheduled) {
            removeEventFromSchedule(event, cell: cell)
        }
        else {
            addEventToSchedule(event, cell: cell)
        }
    }
    
    func addEventToSchedule(event: ScheduleItemDTO, cell: IScheduleTableViewCell) {
        cell.scheduledButtonText = "remove"
        interactor.addEventToLoggedInMemberSchedule(event.id) { error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
        }
    }
    
    func removeEventFromSchedule(event: ScheduleItemDTO, cell: IScheduleTableViewCell) {
        cell.scheduledButtonText = "schedule"
        interactor.removeEventFromLoggedInMemberSchedule(event.id) { error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
        }
    }
    
    func loggedIn(notification: NSNotification) {
        viewController.reloadSchedule()
    }
    
    func loggedOut(notification: NSNotification) {
        viewController.reloadSchedule()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
