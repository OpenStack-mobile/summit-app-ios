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
    func clearFilters(completionBlock: (NSError? -> Void)!)
    func getChildViews() -> [UIViewController]
}

public class EventsPresenter: NSObject, IEventsPresenter {

    var scheduleFilter: ScheduleFilter!
    
    var interactor: IEventsInteractor!
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
        if !interactor.isDataLoaded() {
            viewController.showWarningMessage("No summit data available")
            return
        }
        wireframe.showFilters()
    }
    
    public func clearFilters(completionBlock: (NSError? -> Void)!) {
        scheduleFilter.clearActiveFilters()
        viewController.activeFilterIndicator = false
        
        if (completionBlock != nil) {
            completionBlock(nil)
        }
    }
    
    public func getChildViews() -> [UIViewController] {
        var childViewController: [UIViewController] = []
        
        childViewController.append(generalScheduleViewController)
        childViewController.append(trackListViewController)
        childViewController.append(levelListViewController)
        
        return childViewController
    }
    
}
