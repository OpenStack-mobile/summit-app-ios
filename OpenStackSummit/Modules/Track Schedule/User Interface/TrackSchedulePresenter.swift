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
    
    var isLoaded = false
    
    public func viewLoad(track: TrackDTO) {
        self.track = track
        viewController.track = track.name
        viewLoad()
    }
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [ScheduleItemDTO] {
        let trackSelections = [track.id]
        
        let events = interactor.getScheduleEvents(
            startDate,
            endDate: endDate,
            eventTypes: nil,
            summitTypes: nil,
            tracks: trackSelections,
            trackGroups:  nil,
            tags: nil,
            levels: nil
        )
        
        return events
    }
}
