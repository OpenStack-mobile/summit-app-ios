//
//  Member.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

public class Member: BaseEntity {
    public let scheduledEvents = List<SummitEvent>()
    public let bookmarkedEvents = List<SummitEvent>()
    public dynamic var speakerRole : PresentationSpeaker?
    public dynamic var attendeeRole : SummitAttendee?
}
