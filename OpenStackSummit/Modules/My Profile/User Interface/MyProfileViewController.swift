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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isFirstTime {
            reloadPagerTabStripView()
        }
        isFirstTime = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        navigationController?.navigationBar.topItem?.title = "MY PROFILE"
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return presenter.getChildViews()
    }
}
