//
//  GeneralScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class GeneralScheduleWireframe: NSObject {
    var eventDetailWireframe : IEventDetailWireframe!
    var generalScheduleViewController: GeneralScheduleViewController!
    
    func showEventDetail(eventId: Int) {
        eventDetailWireframe.presentEventDetailView(eventId, viewController: generalScheduleViewController.navigationController!)
    }
}
