//
//  ScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IScheduleWireframe {
    func showEventDetail(eventId: Int)
}

public class ScheduleWireframe: NSObject, IScheduleWireframe {
    var eventDetailWireframe : IEventDetailWireframe!

    public func showEventDetail(eventId: Int) { preconditionFailure("This method must be overridden")  }
    
    public func showEventDetail(eventId: Int, viewController: UIViewController) {
        eventDetailWireframe.presentEventDetailView(eventId, onNavigationViewController: viewController.navigationController!)
    }
}
