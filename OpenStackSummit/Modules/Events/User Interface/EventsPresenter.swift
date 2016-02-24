//
//  EventsPresenter.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventsPresenter {
    func viewLoad()
    func showFilters()
    func getChildViews() -> [UIViewController]
}

public class EventsPresenter: NSObject, IEventsPresenter {

    var scheduleFilter: ScheduleFilter!
    
    var viewController: IEventsViewController!
    var internalWireframe: IEventsWireframe!
    
    var generalScheduleViewController: GeneralScheduleViewController!
    var trackListViewController: TrackListViewController!
    var levelListViewController: LevelListViewController!
    
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
    
    public func getChildViews() -> [UIViewController] {
        var childViewController: [UIViewController] = []
        
        childViewController.append(generalScheduleViewController)
        childViewController.append(trackListViewController)
        childViewController.append(levelListViewController)
        
        return childViewController
    }
    
}
