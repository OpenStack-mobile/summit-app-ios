//
//  MyProfileViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

class MyProfileViewController: RevealTabStripViewController {
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var personalScheduleViewController: PersonalScheduleViewController!
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.topItem?.title = "My Profile"
    }
    
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> [AnyObject] {
        return [personalScheduleViewController]
    }
    
}