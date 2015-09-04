//
//  ScheduleItemDTOAssemblerMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

public class ScheduleItemDTOAssemblerMock : IScheduleItemDTOAssembler {
    
    var scheduleItemDTO: ScheduleItemDTO!
    
    public init(scheduleItemDTO: ScheduleItemDTO) {
        self.scheduleItemDTO = scheduleItemDTO
    }
    
    @objc public func createDTO(event: SummitEvent) -> ScheduleItemDTO {
        return scheduleItemDTO
    }
}
