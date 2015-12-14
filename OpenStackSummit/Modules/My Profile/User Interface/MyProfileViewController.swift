//
//  MyProfileViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MyProfileViewController: RevealTabStripViewController {
    var presenter: IMyProfilePresenter!
    var isFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.topItem?.title = "MY PROFILE"
        if !isFirstTime {
            reloadPagerTabStripView()
        }
        isFirstTime = false
    }

    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> [AnyObject] {
        return presenter.getChildViews()
    }
}
