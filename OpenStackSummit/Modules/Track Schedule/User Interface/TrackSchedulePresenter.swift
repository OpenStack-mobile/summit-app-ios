//
//  TrackSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol TrackSchedulePresenterProtocol: SchedulePresenterProtocol {
    
    func viewLoad(track: RealmTrack)
}

public final class TrackSchedulePresenter: SchedulePresenter, TrackSchedulePresenterProtocol {
    
    var track: RealmTrack!
    
    weak var viewController : TrackScheduleViewController! {
        
        get {
            return internalViewController as! TrackScheduleViewController
        }
        set {
            internalViewController = newValue
        }
    }
    
    var interactor : ScheduleInteractor! {
        get {
            return internalInteractor
        }
        set {
            internalInteractor = newValue
        }
    }
    
    var wireframe : ScheduleWireframe! {
        get {
            return internalWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    public func viewLoad(track: RealmTrack) {
        self.track = track
        viewController.track = track.name
        viewLoad()
    }
    
    override func getScheduleAvailableDatesFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: ScheduleInteractorProtocol) -> [NSDate] {
        
        let trackSelections = [track.id]
        let eventTypeSelections = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let summitTypeSelections = self.scheduleFilter.selections[FilterSectionType.SummitType] as? [Int]
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
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: ScheduleInteractorProtocol) -> [ScheduleItem] {
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
