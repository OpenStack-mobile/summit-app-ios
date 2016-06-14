//
//  ScheduleItemAssemblerMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

public class ScheduleItemAssemblerMock : IScheduleItemAssembler {
    
    var ScheduleItem: ScheduleItem!
    
    public init(ScheduleItem: ScheduleItem) {
        self.ScheduleItem = ScheduleItem
    }
    
    @objc public func createDTO(event: SummitEvent) -> ScheduleItem {
        return ScheduleItem
    }
}
