//
//  Feedback.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public class Feedback: BaseEntity {
    public dynamic var rate = 0
    public dynamic var review = ""
    public dynamic var date = NSDate(timeIntervalSince1970: 1)
    public dynamic var event: SummitEvent!
    public dynamic var owner: SummitAttendee!
}
