//
//  LevelScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class LevelScheduleViewController: ScheduleViewController {
    
    var presenter: ILevelSchedulePresenter! {
        get {
            return internalPresenter as! ILevelSchedulePresenter
        }
        set {
            internalPresenter = newValue
        }
    }
}
