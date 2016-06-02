//
//  RealmFeedback.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmFeedback: RealmEntity {
    
    public dynamic var rate = 0
    public dynamic var review = ""
    public dynamic var date = NSDate(timeIntervalSince1970: 1)
    public dynamic var event: RealmSummitEvent!
    public dynamic var owner: RealmSummitAttendee!
}