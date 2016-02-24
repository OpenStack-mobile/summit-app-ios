//
//  PersonalScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class PersonalScheduleWireframe: ScheduleWireframe {
    var personalScheduleViewController: PersonalScheduleViewController!

    public override func showEventDetail(eventId: Int) {
        super.showEventDetail(eventId, fromViewController: personalScheduleViewController)
    }
}
