//
//  EventsViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

@objc
protocol IEventsViewController {
    var activeFilterIndicator: Bool { get set }
}

class EventsViewController: RevealTabStripViewController, IEventsViewController {
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var activeFilterIndicator = false {
        didSet {
            filterButton.tintColor = activeFilterIndicator ? UIColor(hexaString: "#F8E71C") : UIColor.whiteColor()
        }
    }
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewLoad()
    }
    
    func showFilters(sender: UIBarButtonItem) {
        presenter.showFilters()
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [generalScheduleViewController, trackListViewController, levelListViewController]
    }
    
}