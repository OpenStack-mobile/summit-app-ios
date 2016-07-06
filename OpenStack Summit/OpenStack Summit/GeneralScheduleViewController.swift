//
//  GeneralScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import UIKit
import XLPagerTabStrip
import SwiftSpinner
import CoreSummit

class GeneralScheduleViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var noConnectivityView: UIView!
    
    @IBOutlet weak var retryButton: UIButton!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    // MARK: - Actions
    
    @IBAction func retryButtonPressed(sender: UIButton) {
        
        loadData()
    }
    
    // MARK: - Methods
    
    override func toggleEventList(show: Bool) {
        
        scheduleView.hidden = !show
    }
    
    override func toggleNoConnectivityMessage(show: Bool) {
        
        noConnectivityView.hidden = !show
    }
    
    internal override func loadData() {
        
        if !scheduleFilter.hasToRefreshSchedule {
            return
        }
        
        self.showActivityIndicator()
        
        scheduleFilter.hasToRefreshSchedule = false
        
        if Store.shared.realm.objects(RealmSummit).isEmpty && Reachability.connected == false {
            
            self.toggleNoConnectivityMessage(true)
            self.toggleEventList(false)
            return
        }
        
        self.toggleNoConnectivityMessage(false)
        self.toggleEventList(true)
        
        self.checkForClearDataEvents()
        
        super.loadData()
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func checkForClearDataEvents() {
        
        //dataUpdatePoller.clearDataIfTruncateEventExist()
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
