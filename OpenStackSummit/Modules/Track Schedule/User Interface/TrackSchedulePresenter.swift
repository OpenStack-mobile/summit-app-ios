//
//  TrackSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackSchedulePresenter: ISchedulePresenter{
    func viewLoad(track: TrackDTO)
}

public class TrackSchedulePresenter: SchedulePresenter, ITrackSchedulePresenter {
    var track: TrackDTO!
    
    weak var viewController : ITrackScheduleViewController! {
        get {
            return internalViewController as! ITrackScheduleViewController
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
    
    public func viewLoad(track: TrackDTO) {
        self.track = track
        viewController.track = track.name
        viewLoad()
    }
    
    override func getScheduledEventsActiveDatesSince(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [NSDate] {
        let trackSelections = [track.id]
        let eventTypeSelections = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let summitTypeSelections = self.scheduleFilter.selections[FilterSectionType.SummitType] as? [Int]
        let trackGroupSelections = self.scheduleFilter.selections[FilterSectionType.TrackGroup] as? [Int]
        let tagSelections = self.scheduleFilter.selections[FilterSectionType.Tag] as? [String]
        let levelSelections = self.scheduleFilter.selections[FilterSectionType.Level] as? [String]
        
        let activeDates = interactor.getActiveSummitDates(
            startDate,
            endDate: endDate,
            eventTypes: eventTypeSelections,
            summitTypes: summitTypeSelections,
            tracks: trackSelections,
            trackGroups: trackGroupSelections,
            tags: tagSelections,
            levels: levelSelections
        )
        
        return activeDates
    }
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [ScheduleItemDTO] {
        let trackSelections = [track.id]
        let eventTypeSelections = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let summitTypeSelections = self.scheduleFilter.selections[FilterSectionType.SummitType] as? [Int]
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
