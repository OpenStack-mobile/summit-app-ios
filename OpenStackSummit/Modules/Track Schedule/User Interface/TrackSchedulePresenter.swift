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
    func viewLoad(trackId: Int)
}

public class TrackSchedulePresenter: SchedulePresenter, ITrackSchedulePresenter {
    var trackId = 0
    
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
    
    public func viewLoad(trackId: Int) {
        self.trackId = trackId
        viewLoad()
    }
    
    public override func reloadSchedule() {
        scheduleFilter.selections[FilterSectionTypes.Track] = [Int]()
        scheduleFilter.selections[FilterSectionTypes.Track]!.append(trackId)
        reloadSchedule(interactor, viewController: viewController)
    }
}
