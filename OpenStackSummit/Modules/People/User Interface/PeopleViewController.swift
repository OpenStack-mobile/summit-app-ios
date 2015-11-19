//
//  PeopleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PeopleViewController: RevealTabStripViewController {
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var attendeesListViewController: AttendeesListViewController!
    var speakersListViewController: SpeakerListViewController!
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.topItem?.title = "PEOPLE"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> [AnyObject] {
        return [speakersListViewController, attendeesListViewController]
    }
}
