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
    
    let attendeesListViewController = R.storyboard.people.attendeesListViewController()!
    let speakersListViewController = R.storyboard.people.speakerListViewController()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "PEOPLE"
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [speakersListViewController, attendeesListViewController]
    }
}
