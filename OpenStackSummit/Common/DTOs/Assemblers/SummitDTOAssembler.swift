//
//  SummitDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISummitDTOAssembler {
    func createDTO(summit: Summit)->SummitDTO
}

public class SummitDTOAssembler: NSObject {
    public func createDTO(summit: Summit)->SummitDTO{
        let summitDTO = SummitDTO()
        summitDTO.name = summit.name
        summitDTO.startDate = summit.startDate
        summitDTO.endDate = summit.endDate
        summitDTO.timeZone = summit.timeZone
        
        return summitDTO
    }
}
