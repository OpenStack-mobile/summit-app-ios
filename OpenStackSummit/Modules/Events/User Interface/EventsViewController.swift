//
//  EventsViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip
import KTCenterFlowLayout

@objc
protocol IEventsViewController {
    var activeFilterIndicator: Bool { get set }
}

class EventsViewController: RevealTabStripViewController, IEventsViewController {
    
    var filterButton: UIBarButtonItem?
    
    var activeFilterIndicator = false {
        didSet {
            filterButton?.tintColor = activeFilterIndicator ? UIColor(hexaString: "#F8E71C") : UIColor.whiteColor()
        }
    }

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
        
        filterButton = UIBarButtonItem(title:"Filter", style: .Plain, target: self, action: Selector("showFilters:"))
        filterButton!.image = UIImage(named: "filter")
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewLoad()
    }
    
    func showFilters(sender: UIBarButtonItem) {
        presenter.showFilters()
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return presenter.getChildViews()
    }
    
}