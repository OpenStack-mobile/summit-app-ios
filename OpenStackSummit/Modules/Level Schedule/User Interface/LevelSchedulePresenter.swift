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
    
    var isLoaded = false
    
    public func viewLoad(level: String) {
        self.level = level
        viewController.title = level.uppercaseString
        viewLoad()
    }
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [ScheduleItemDTO] {
        let levelSelections = [level]
        
        let events = interactor.getScheduleEvents(
            startDate,
            endDate: endDate,
            eventTypes: nil,
            summitTypes: nil,
            tracks: nil,
            trackGroups: nil,
            tags: nil,
            levels: levelSelections
        )
        
        return events
    }
}
