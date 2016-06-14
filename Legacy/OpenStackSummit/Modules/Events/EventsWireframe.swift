//
//  EventsWireframe.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

@objc
public protocol IEventsWireframe {
    func pushEventsView()
    func showFilters()
}

public class EventsWireframe: NSObject, IEventsWireframe {
    var navigationController: NavigationController!
    var revealViewController: SWRevealViewController!
    var eventsViewController: EventsViewController!
    var generalScheduleFilterWireframe: IGeneralScheduleFilterWireframe!
    
    public func pushEventsView() {
        navigationController.setViewControllers([eventsViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    public func showFilters() {
        generalScheduleFilterWireframe.presentFiltersView(eventsViewController.navigationController!)
    }
    
}
