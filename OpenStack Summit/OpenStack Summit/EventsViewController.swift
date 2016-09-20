//
//  EventsViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip
import KTCenterFlowLayout
import SwiftSpinner
import CoreSummit

final class EventsViewController: RevealTabStripViewController, ShowActivityIndicatorProtocol, MessageEnabledViewController, GeneralScheduleFilterViewControllerDelegate {
    
    // MARK: - Properties
    
    // Child VCs
    let generalScheduleViewController = R.storyboard.schedule.generalScheduleViewController()!
    let trackListViewController = R.storyboard.tracks.trackListViewController()!
    let levelListViewController = R.storyboard.levels.levelListViewController()!
    
    private(set) var filterButton: UIBarButtonItem!
    
    var activeFilterIndicator = false {
        
        didSet {
            
            filterButton?.tintColor = activeFilterIndicator ? UIColor(hexaString: "#F8E71C") : UIColor.whiteColor()
            navigationController?.toolbar.barTintColor = UIColor(hexaString: "#F8E71C")
            navigationController?.toolbar.translucent = false
            navigationController?.setToolbarHidden(!activeFilterIndicator, animated: !activeFilterIndicator)
        }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "EVENTS"
        
        filterButton = UIBarButtonItem()
        filterButton.target = self
        filterButton.action = #selector(EventsViewController.showFilters(_:))
        filterButton.image = UIImage(named: "filter")
        
        navigationItem.rightBarButtonItem = filterButton
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
        
        let message = UIBarButtonItem()
        message.title = "CLEAR ACTIVE FILTERS"
        message.style = .Plain
        message.target = self
        message.action = #selector(EventsViewController.clearFilters(_:))
        message.tintColor = UIColor(hexaString: "#4A4A4A")
        message.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(15)], forState: .Normal)

        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: #selector(EventsViewController.clearFilters(_:)))
        
        let clear = UIBarButtonItem()
        clear.target = self
        clear.action = #selector(EventsViewController.clearFilters(_:))
        clear.image = UIImage(named: "cancel")
        clear.tintColor = UIColor.blackColor()
        
        toolbarItems = [message, spacer, clear]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activeFilterIndicator = generalScheduleViewController.scheduleFilter.hasActiveFilters()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.toolbarHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func showFilters(sender: UIBarButtonItem) {
        
        guard Store.shared.realm.objects(RealmSummit).count > 0  else {
            
            showInfoMessage("Info", message: "No summit data available")
            return
        }
        
        let generalScheduleFilterViewController = R.storyboard.scheduleFilter.generalScheduleFilterViewController()!
        let navigationController = UINavigationController(rootViewController: generalScheduleFilterViewController)
        
        navigationController.modalPresentationStyle = .FormSheet
        generalScheduleFilterViewController.scheduleFilter = generalScheduleViewController.scheduleFilter
        generalScheduleFilterViewController.delegate = self
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func clearFilters(sender: UIBarButtonItem) {
        
        generalScheduleViewController.scheduleFilter.clearActiveFilters()
        self.activeFilterIndicator = false
        
        self.reloadPagerTabStripView()
    }
    
    // MARK: - GeneralScheduleFilterViewControllerDelegate
    
    func scheduleFilterController(controller: GeneralScheduleFilterViewController, didUpdateFilter filter: ScheduleFilter) {
        
        activeFilterIndicator = filter.hasActiveFilters()
        
        generalScheduleViewController.scheduleFilter = filter
        trackListViewController.scheduleFilter = filter
        levelListViewController.scheduleFilter = filter
    }
    
    // MARK: - RevealTabStripViewController
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        return [generalScheduleViewController, trackListViewController, levelListViewController]
    }
}
