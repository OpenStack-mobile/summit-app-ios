//
//  PersonalScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner

class PersonalScheduleViewController: ScheduleViewController {
    var presenter: ISchedulePresenter! {
        get {
            return internalPresenter
        }
        set {
            internalPresenter = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewLoad()
    }
    
    override func showActivityIndicator() {
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    override func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
}
