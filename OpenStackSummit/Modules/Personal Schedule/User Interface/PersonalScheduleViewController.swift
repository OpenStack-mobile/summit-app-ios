//
//  PersonalScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftSpinner

class PersonalScheduleViewController: ScheduleViewController, IndicatorInfoProvider {
    var presenter: SchedulePresenterProtocol! {
        get {
            return internalPresenter
        }
        set {
            internalPresenter = newValue
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewLoad()
    }
    
    override func showActivityIndicator() {
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    override func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Schedule")
    }
}
