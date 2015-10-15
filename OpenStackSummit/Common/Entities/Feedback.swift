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
    dynamic var rate = 0
    dynamic var review = ""
    dynamic var date = NSDate(timeIntervalSince1970: 1)
    dynamic var event: SummitEvent!
    dynamic var owner: SummitAttendee!
}
