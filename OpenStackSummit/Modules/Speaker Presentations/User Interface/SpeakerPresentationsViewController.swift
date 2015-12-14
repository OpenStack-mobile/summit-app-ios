//
//  SpeakerPresentationsViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftSpinner

@objc
protocol ISpeakerPresentationsViewController: IScheduleViewController {
    var presenter: ISpeakerPresentationsPresenter! { get set }
}

class SpeakerPresentationsViewController: ScheduleViewController, XLPagerTabStripChildItem, ISpeakerPresentationsViewController {
    var presenter: ISpeakerPresentationsPresenter! {
        get {
            return internalPresenter as! ISpeakerPresentationsPresenter
        }
        set {
            internalPresenter = newValue
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        presenter.viewLoad()
    }
    
    override func showActivityIndicator() {
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    override func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> String {
        return "Sessions"
    }
}
