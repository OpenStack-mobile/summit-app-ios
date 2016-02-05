//
//  LevelSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ILevelSchedulePresenter: ISchedulePresenter{
    func viewLoad(level: String)
}

public class LevelSchedulePresenter: SchedulePresenter, ILevelSchedulePresenter {
    var level = ""
    
    weak var viewController : IScheduleViewController! {
        get {
            return internalViewController
        }
        set {
            internalViewController = newValue
        }
    }
    
    var interactor : IScheduleInteractor! {
        get {
            return internalInteractor
        }
        set {
            internalInteractor = newValue
        }
    }
    
    var wireframe : IScheduleWireframe! {
        get {
            return internalWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    public func viewLoad(level: String) {
        self.level = level
        viewController.title = level.uppercaseString
        viewLoad()
    }
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [ScheduleItemDTO] {
        let levelSelections = [level]
        
        let eventTypeSelections = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let summitTypeSelections = self.scheduleFilter.selections[FilterSectionType.SummitType] as? [Int]
        let trackSelections = self.scheduleFilter.selections[FilterSectionType.Track] as? [Int]
        let trackGroupSelections = self.scheduleFilter.selections[FilterSectionType.TrackGroup] as? [Int]
        let tagSelections = self.scheduleFilter.selections[FilterSectionType.Tag] as? [String]

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
