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
    func showFilters()
}

public class GeneralScheduleWireframe: ScheduleWireframe, IGeneralScheduleWireframe {
    var generalScheduleViewController: GeneralScheduleViewController!
    var generalScheduleFilterWireframe: IGeneralScheduleFilterWireframe!
    
    public override func showEventDetail(eventId: Int) {
        super.showEventDetail(eventId, fromViewController: generalScheduleViewController)
    }
    
    public func showFilters() {
        generalScheduleFilterWireframe.presentFiltersView(generalScheduleViewController)
    }
}
		