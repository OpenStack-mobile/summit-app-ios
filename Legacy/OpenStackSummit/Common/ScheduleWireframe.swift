//
//  ScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol ScheduleWireframe: class {
    
    var eventDetailWireframe: EventDetailWireframe { get }
    
    func showEventDetail(eventID: Int)
}

public extension ScheduleWireframe {
    
    public func showEventDetail(eventId: Int, fromViewController viewController: UIViewController) {
        
        eventDetailWireframe.pushEventDetailView(eventId, toNavigationViewController: viewController.navigationController!)
    }
}
