//
//  PeopleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

final class PeopleViewController: RevealTabStripViewController {
    
    var attendeesListViewController: AttendeesListViewController!
    var speakersListViewController: SpeakerListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "PEOPLE"
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [speakersListViewController, attendeesListViewController]
    }
}
