//
//  SummitAttendeeDTOAssemblerMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class SummitAttendeeDTOAssemblerMock: NSObject, ISummitAttendeeDTOAssembler {
    var summitAttendeeDTO: SummitAttendeeDTO
    
    init(summitAttendeeDTO: SummitAttendeeDTO) {
        self.summitAttendeeDTO = summitAttendeeDTO
    }
    
    func createDTO(summitAttendee: SummitAttendee) -> SummitAttendeeDTO {
        return summitAttendeeDTO
    }
}