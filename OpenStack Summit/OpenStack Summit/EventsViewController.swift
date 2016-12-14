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

final class EventsViewController: RevealTabStripViewController, ShowActivityIndicatorProtocol, MessageEnabledViewController {
    
    // MARK: - Properties
    
    // Child VCs
    let generalScheduleViewController = R.storyboard.schedule.generalScheduleViewController()!
    let trackListViewController = R.storyboard.tracks.trackListViewController()!
    let levelListViewController = R.storyboard.levels.levelListViewController()!
    
    private(set) var filterButton: UIBarButtonItem!
    
    private(set) var activeFilterIndicator = false {
        
        didSet {
            
            filterButton?.tintColor = activeFilterIndicator ? UIColor(hexaString: "#F8E71C") : UIColor.whiteColor()
            navigationController?.toolbar.barTintColor = UIColor(hexaString: "#F8E71C")
            navigationController?.toolbar.translucent = false
            navigationController?.setToolbarHidden(!activeFilterIndicator, animated: !activeFilterIndicator)
        }
    }
    
    private var filterObserver: Int?
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = filterObserver { FilterManager.shared.filter.remove(observer) }
    }
    
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
        
        filterObserver = FilterManager.shared.filter.observe(filterChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        activeFilterIndicator = FilterManager.shared.filter.value.hasActiveFilters()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.toolbarHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func showFilters(sender: UIBarButtonItem) {
        
        guard try! Store.shared.managedObjectContext.managedObjects(SummitManagedObject).count > 0  else {
            
            showInfoMessage("Info", message: "No summit data available")
            return
        }
        
        let generalScheduleFilterViewController = R.storyboard.scheduleFilter.generalScheduleFilterViewController()!
        let navigationController = UINavigationController(rootViewController: generalScheduleFilterViewController)
        navigationController.modalPresentationStyle = .FormSheet
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func clearFilters(sender: UIBarButtonItem) {
        
        FilterManager.shared.filter.value.clearActiveFilters()
        
        self.reloadPagerTabStripView()
    }
    
    // MARK: - Private Methods
    
    private func filterChanged(filter: ScheduleFilter) {
        
        if self.navigationController?.topViewController === self {
            
            self.activeFilterIndicator = filter.hasActiveFilters()
        }
    }
    
    // MARK: - RevealTabStripViewController
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        return [generalScheduleViewController, trackListViewController, levelListViewController]
    }
}
