//
//  MemberProfileDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class MemberProfileDTO: NSObject {
    public var name = ""
    public var jobTitle = ""
    public var pictureUrl = ""
    public var bio = ""
    public var twitter = ""
    public var IRC = ""
    public var email = ""
    public var location = ""
    public var events = [ScheduleItemDTO]()
}
