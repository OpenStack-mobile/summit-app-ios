//
//  GeneralScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IGeneralScheduleWireframe {
    func showEventDetail(eventId: Int)
    func presentGeneralScheduleView(viewController: UINavigationController)
}

public class GeneralScheduleWireframe: NSObject {
    var eventDetailWireframe : IEventDetailWireframe!
    var generalScheduleViewController: GeneralScheduleViewController!
    
    public func showEventDetail(eventId: Int) {
        eventDetailWireframe.presentEventDetailView(eventId, viewController: generalScheduleViewController.navigationController!)
    }
    
    public func presentGeneralScheduleView(viewController: UINavigationController) {
        
    }
}
		