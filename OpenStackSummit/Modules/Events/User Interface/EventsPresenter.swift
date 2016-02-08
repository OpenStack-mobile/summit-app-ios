//
//  EventsPresenter.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation

@objc
public protocol IEventsPresenter {
    func viewLoad()
    func showFilters()
}

public class EventsPresenter: NSObject, IEventsPresenter {

    var scheduleFilter: ScheduleFilter!
    
    var viewController: IEventsViewController!
    var internalWireframe: IEventsWireframe!
    
    var wireframe : IEventsWireframe! {
        get {
            return internalWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    public func viewLoad() {
        viewController.activeFilterIndicator = scheduleFilter.hasActiveFilters()
    }
    
    public func showFilters() {
        wireframe.showFilters()
    }
}
