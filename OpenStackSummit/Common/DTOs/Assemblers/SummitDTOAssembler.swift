//
//  CoreSummit.SummitAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ICoreSummit.SummitAssembler {
    func createDTO(summit: Summit)->CoreSummit.Summit
}

public class CoreSummit.SummitAssembler: NamedDTOAssembler {
    public func createDTO(summit: Summit)->CoreSummit.Summit{
        let CoreSummit.Summit: CoreSummit.Summit = super.createDTO(summit)
        CoreSummit.Summit.startDate = summit.startDate
        CoreSummit.Summit.endDate = summit.endDate
        CoreSummit.Summit.timeZone = summit.timeZone
        
        return CoreSummit.Summit
    }
}
