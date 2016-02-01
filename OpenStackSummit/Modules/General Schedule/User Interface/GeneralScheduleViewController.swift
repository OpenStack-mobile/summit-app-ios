//
//  ScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import UIKit
import XLPagerTabStrip
import SwiftSpinner

class GeneralScheduleViewController: ScheduleViewController, IndicatorInfoProvider {
    
    var presenter: IGeneralSchedulePresenter! {
        get {
            return internalPresenter as! IGeneralSchedulePresenter
        }
        set {
            internalPresenter = newValue
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources t	hat can be recreated.
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
