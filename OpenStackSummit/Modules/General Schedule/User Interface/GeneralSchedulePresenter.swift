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
public protocol IGeneralSchedulePresenter: ISchedulePresenter {
}

public class GeneralSchedulePresenter: SchedulePresenter, IGeneralSchedulePresenter {
    
    weak var viewController : IGeneralScheduleViewController! {
        get {
            return internalViewController as! IGeneralScheduleViewController
        }
        set {
            internalViewController = newValue
        }
    }
    
    var interactor : IGeneralScheduleInteractor! {
        get {
            return internalInteractor as! IGeneralScheduleInteractor
        }
        set {
            internalInteractor = newValue
        }
    }
    
    var wireframe : IGeneralScheduleWireframe! {
        get {
            return internalWireframe as! IGeneralScheduleWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    override public func viewLoad() {
        if !scheduleFilter.hasToRefreshSchedule {
            return
        }
        
        viewController.showActivityIndicator()
        
        scheduleFilter.hasToRefreshSchedule = false
        
        if !interactor.isDataLoaded() && !interactor.isNetworkAvailable() {
            viewController.toggleNoConnectivityMessage(true)
            viewController.toggleEventList(false)
            return
        }
        
        viewController.toggleNoConnectivityMessage(false)
        viewController.toggleEventList(true)
        
        interactor.checkForClearDataEvents()
        
        super.viewLoad()
    }
    
    override func getScheduleAvailableDatesFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [NSDate] {
        let eventTypeSelections = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let summitTypeSelections = self.scheduleFilter.selections[FilterSectionType.SummitType] as? [Int]
        let trackSelections = self.scheduleFilter.selections[FilterSectionType.Track] as? [Int]
        let trackGroupSelections = self.scheduleFilter.selections[FilterSectionType.TrackGroup] as? [Int]
        let tagSelections = self.scheduleFilter.selections[FilterSectionType.Tag] as? [String]
        let levelSelections = self.scheduleFilter.selections[FilterSectionType.Level] as? [String]
        
        let availableDates = interactor.getScheduleAvailableDates(
            startDate,
            endDate: endDate,
            eventTypes: eventTypeSelections,
            summitTypes: summitTypeSelections,
            tracks: trackSelections,
            trackGroups: trackGroupSelections,
            tags: tagSelections,
            levels: levelSelections
        )
        
        return availableDates
    }
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [ScheduleItemDTO] {
        let eventTypeSelections = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let summitTypeSelections = self.scheduleFilter.selections[FilterSectionType.SummitType] as? [Int]
        let trackSelections = self.scheduleFilter.selections[FilterSectionType.Track] as? [Int]
        let trackGroupSelections = self.scheduleFilter.selections[FilterSectionType.TrackGroup] as? [Int]
        let tagSelections = self.scheduleFilter.selections[FilterSectionType.Tag] as? [String]
        let levelSelections = self.scheduleFilter.selections[FilterSectionType.Level] as? [String]
        
        let events = interactor.getScheduleEvents(
            startDate,
            endDate: endDate,
            eventTypes: eventTypeSelections,
            summitTypes: summitTypeSelections,
            tracks: trackSelections,
            trackGroups: trackGroupSelections,
            tags: tagSelections,
            levels: levelSelections
        )
        
        return events
    }
}
