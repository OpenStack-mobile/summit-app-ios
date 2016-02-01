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
    var levelListViewController: LevelListViewController!

    var internalPresenter: IEventsPresenter!
    
    var presenter: IEventsPresenter! {
        get {
            return internalPresenter as IEventsPresenter
        }
        set {
            internalPresenter = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "EVENTS"
        
        if (filterButton != nil) {
            filterButton.target = self
            filterButton.action = Selector("showFilters:")
        }
    }

    func showFilters(sender: UIBarButtonItem) {
        presenter.showFilters()
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [generalScheduleViewController, trackListViewController, levelListViewController]
    }
    
}