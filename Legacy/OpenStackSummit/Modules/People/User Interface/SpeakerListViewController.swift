//
//  SpeakerViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SpeakerListViewController: PeopleListViewController, IndicatorInfoProvider {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.speakersListViewLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.speakersListViewWillAppear();
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Speakers")
    }
}
