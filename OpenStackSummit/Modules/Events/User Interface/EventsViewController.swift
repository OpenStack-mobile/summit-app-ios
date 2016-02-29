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
    
    var filterButton: UIBarButtonItem!
    
    var activeFilterIndicator = false {
        didSet {
            filterButton?.tintColor = activeFilterIndicator ? UIColor(hexaString: "#F8E71C") : UIColor.whiteColor()
            navigationController?.setToolbarHidden(!activeFilterIndicator, animated: true)
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
        
        filterButton = UIBarButtonItem()
        filterButton.target = self
        filterButton.action = Selector("showFilters:")
        filterButton.image = UIImage(named: "filter")
        
        navigationItem.rightBarButtonItem = filterButton
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
        
        let message = UIBarButtonItem()
        message.title = "CLEAR ACTIVE FILTERS"
        message.style = .Plain
        message.target = self
        message.action = Selector("clearFilters:")
        message.tintColor = UIColor(hexaString: "#4A4A4A")
        message.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(15)], forState: UIControlState.Normal)

        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: Selector("clearFilters:"))
        
        let clear = UIBarButtonItem()
        clear.target = self
        clear.action = Selector("clearFilters:")
        clear.image = UIImage(named: "cancel")
        clear.tintColor = UIColor.blackColor()
        
        toolbarItems = [message, spacer, clear]
        navigationController?.toolbar.barTintColor = UIColor(hexaString: "#F8E71C")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.toolbarHidden = true
    }
    
    func showFilters(sender: UIBarButtonItem) {
        presenter.showFilters()
    }
    
    func clearFilters(sender: UIBarButtonItem) {
        presenter.clearFilters { (error) -> Void in
            self.reloadPagerTabStripView()
        }
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return presenter.getChildViews()
    }
    
}