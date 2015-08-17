//
//  GeneralScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class GeneralScheduleInteractor: NSObject {
    var delegate : GeneralSchedulePresenter?
    
    func getScheduleEventsAsync(){
        if (delegate != nil) {
            let events = ["Event1", "Event2", "Event3"]
            delegate?.reloadSchedule(events)
        }
    }
}
