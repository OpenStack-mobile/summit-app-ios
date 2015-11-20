//
//  SpeakerViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SpeakerListViewController: PeopleListViewController, XLPagerTabStripChildItem {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.speakersListViewLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.speakersListViewWillAppear();
    }
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> String {
        return "Speakers"
    }
}
