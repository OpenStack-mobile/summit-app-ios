//
//  SummitDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class SummitDTO: NSObject {
    public var name = ""
    public var startDate = NSDate(timeIntervalSince1970: 1)
    public var endDate = NSDate(timeIntervalSince1970: 1)
    public var timeZone = ""
}
