//
//  AttendeesViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

final class AttendeesListViewController: PeopleListViewController, IndicatorInfoProvider {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.attendeesListViewLoad()
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Attendees")
    }
}
