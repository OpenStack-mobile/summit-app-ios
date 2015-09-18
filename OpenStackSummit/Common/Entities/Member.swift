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

public class Member: Person {
    public dynamic var speakerRole : PresentationSpeaker?
    public dynamic var attendeeRole : SummitAttendee?
    public let friends = List<Member>()

    public func isFriend(member: Member) -> Bool {
        let isFriend = friends.filter({ friend in friend.id == member.id }).count > 0
        return isFriend
    }
}
