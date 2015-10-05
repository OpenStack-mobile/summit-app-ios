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
    var session: ISession!
    var summitTimeZoneOffsetToLocalTimeZone: Int!
    
    public func viewLoad() {
        viewController.showActivityIndicator()
        interactor.getActiveSummit() { summit, error in
            defer { self.viewController.hideActivityIndicator() }
            
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            
            let offsetLocalTimeZone = -NSTimeZone.localTimeZone().secondsFromGMT
            self.summitTimeZoneOffsetToLocalTimeZone = NSTimeZone(name: summit!.timeZone)!.secondsFromGMT + offsetLocalTimeZone
            self.viewController.startDate = summit!.startDate.mt_dateSecondsAfter(offsetLocalTimeZone)
            self.viewController.endDate = summit!.endDate.mt_dateSecondsAfter(offsetLocalTimeZone).mt_dateDaysAfter(1)
            self.viewController.selectedDate = self.viewController.startDate
        }
    }
    
    public func reloadSchedule() {
        let filterSelections = session.get(Constants.SessionKeys.GeneralScheduleFilterSelections) as? Dictionary<FilterSectionTypes, [Int]>
        let startDate = viewController.selectedDate.mt_dateSecondsAfter(-summitTimeZoneOffsetToLocalTimeZone)
        let endDate = viewController.selectedDate.mt_dateDaysAfter(1).mt_dateSecondsAfter(-summitTimeZoneOffsetToLocalTimeZone)
        
        let events = self.interactor.getScheduleEvents(
            startDate,
            endDate: endDate,
            eventTypes: filterSelections?[FilterSectionTypes.EventType],
            summitTypes: filterSelections?[FilterSectionTypes.SummitType]
        )
        self.viewController.dayEvents = events
        self.viewController.reloadSchedule()
    }
    
    func showEventDetail(eventId: Int) {
        self.generalScheduleWireframe.showEventDetail(eventId)
    }
}
