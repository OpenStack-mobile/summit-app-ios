//
//  EventsViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

class EventsViewController: RevealButtonBarTabStripViewController {

    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var isReload: Bool = false
    //var generalScheduleViewController: GeneralScheduleViewController!
    var trackListViewController: TrackListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isProgressiveIndicator = false
        buttonBarView.selectedBar.backgroundColor = UIColor.orangeColor()
        buttonBarView.registerNib(UINib(nibName: "ButtonCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
    
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> [AnyObject] {
        return [trackListViewController]
    }
    
    override func reloadPagerTabStripView() {
        self.isReload = true
        self.isProgressiveIndicator = (rand() % 2 == 0)
        self.isElasticIndicatorLimit = (rand() % 2 == 0)
        super.reloadPagerTabStripView()
    }
}