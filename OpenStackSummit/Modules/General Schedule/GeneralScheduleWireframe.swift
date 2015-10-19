//
//  GeneralScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IGeneralScheduleWireframe: IScheduleWireframe {
    func presentGeneralScheduleView(viewController: UINavigationController)
}

public class GeneralScheduleWireframe: ScheduleWireframe {
    weak var generalScheduleViewController: GeneralScheduleViewController!
    
    public override func showEventDetail(eventId: Int) {
        super.showEventDetail(eventId, viewController: generalScheduleViewController)
    }
    
    public func presentGeneralScheduleView(viewController: UINavigationController) {
        
    }
}
		