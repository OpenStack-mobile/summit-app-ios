//
//  RealmMember.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmMember: RealmPerson {
    public dynamic var speakerRole : RealmPresentationSpeaker?
    public dynamic var attendeeRole : RealmSummitAttendee?
    public let friends = List<RealmMember>()
    
    public func isFriend(member: RealmMember) -> Bool {
        let isFriend = friends.filter({ friend in friend.id == member.id }).count > 0
        return isFriend
    }
}