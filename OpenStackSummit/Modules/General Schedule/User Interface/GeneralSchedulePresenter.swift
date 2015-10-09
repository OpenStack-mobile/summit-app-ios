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
    func showEventDetail(index: Int)
    func viewLoad()
    func buildCell(cell: IGeneralScheduleTableViewCell, index: Int)
    func getDayEventsCount() -> Int
    func toggleEventFromSchedule(index: Int, cell: IGeneralScheduleTableViewCell)
}

public class GeneralSchedulePresenter: NSObject, IGeneralSchedulePresenter {
    
    weak var viewController : IGeneralScheduleViewController!
    var interactor : GeneralScheduleInteractor!
    var generalScheduleWireframe : IGeneralScheduleWireframe!
    var session: ISession!
    var summitTimeZoneOffsetLocalTimeZone: Int!
    var dayEvents: [ScheduleItemDTO]!
    
    public func viewLoad() {
        viewController.showActivityIndicator()
        interactor.getActiveSummit() { summit, error in
            defer { self.viewController.hideActivityIndicator() }
            
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
    
    public func buildCell(cell: IGeneralScheduleTableViewCell, index: Int){
        let event = dayEvents[index]
        cell.eventTitle = event.title
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
    
    public func toggleEventFromSchedule(index: Int, cell: IGeneralScheduleTableViewCell) {
        let event = dayEvents[index]
        let isScheduled = interactor.isEventScheduledByLoggedUser(event.id)
        if (isScheduled) {
            removeEventFromSchedule(event, cell: cell)
        }
        else {
            addEventToSchedule(event, cell: cell)
        }
    }
    
    func addEventToSchedule(event: ScheduleItemDTO, cell: IGeneralScheduleTableViewCell) {
        cell.scheduledButtonText = "remove"
        interactor.addEventToLoggedInMemberSchedule(event.id) { error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
        }
    }
    
    func removeEventFromSchedule(event: ScheduleItemDTO, cell: IGeneralScheduleTableViewCell) {
        cell.scheduledButtonText = "schedule"
        interactor.removeEventFromLoggedInMemberSchedule(event.id) { error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
        }
    }
    
}
