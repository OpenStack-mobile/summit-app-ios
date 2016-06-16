//
//  SpeakerListViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

final class SpeakerListViewController: PeopleListViewController, IndicatorInfoProvider {
    
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
