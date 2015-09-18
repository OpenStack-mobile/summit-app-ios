//
//  MemberProfileDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class MemberProfileDTO: NSObject {
    public var id = 0
    public var name = ""
    public var title = ""
    public var pictureUrl = ""
    public var bio = ""
    public var twitter = ""
    public var irc = ""
    public var email = ""
    public var location = ""
    public var isAttendee = false
    public var isSpeaker = false
    public var scheduledEvents = [ScheduleItemDTO]()
    public var presentations = [ScheduleItemDTO]()
}
