//
//  EventsWireframe.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventsWireframe {
    func showFilters()
}

public class EventsWireframe: NSObject, IEventsWireframe {
    weak var eventsViewController: EventsViewController!
    var generalScheduleFilterWireframe: IGeneralScheduleFilterWireframe!
    
    public func showFilters() {
        generalScheduleFilterWireframe.presentFiltersView(eventsViewController.navigationController!)
    }
}
