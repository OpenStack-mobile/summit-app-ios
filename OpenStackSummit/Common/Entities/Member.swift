//
//  Member.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

@objc public enum MemberRoles: Int {
    case Anonymous, Attendee, Speaker
}

public class Member: BaseEntity {
    public dynamic var firstName = ""
    public dynamic var lastName = ""
    public dynamic var jobTitle = ""
    public dynamic var pictureUrl = ""
    public dynamic var bio = ""
    public dynamic var twitter = ""
    public dynamic var IRC = ""
    public dynamic var email = ""
    public dynamic var location = ""
    public let scheduledEvents = List<SummitEvent>()
    public let bookmarkedEvents = List<SummitEvent>()
    public dynamic var speakerRole : PresentationSpeaker?
    public dynamic var attendeeRole : SummitAttendee?
    public let friends = List<Member>()
    public var presentations: [Presentation] {
        return linkingObjects(Presentation.self, forProperty: "speakers")
    }

    public func isFriend(member: Member) -> Bool {
        let isFriend = friends.filter({ friend in friend.id == member.id }).count > 0
        return isFriend
    }
}
