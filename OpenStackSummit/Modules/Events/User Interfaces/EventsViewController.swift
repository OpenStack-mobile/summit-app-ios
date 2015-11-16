//
//  EventsViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

class EventsViewController: RevealTabStripViewController {
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var generalScheduleViewController: GeneralScheduleViewController!
    var trackListViewController: TrackListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBarView.registerNib(UINib(nibName: "ButtonCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
    
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> [AnyObject] {
        return [generalScheduleViewController, trackListViewController]
    }
    
}