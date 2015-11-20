//
//  AttendeesViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AttendeesListViewController: PeopleListViewController, XLPagerTabStripChildItem {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.attendeesListViewLoad()
    }
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> String {
        return "Attendees"
    }
}
