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

class GeneralScheduleViewController: ScheduleViewController, IndicatorInfoProvider, ShowActivityIndicatorProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var noConnectivityView: UIView!
    
    @IBOutlet weak var retryButton: UIButton!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func retryButtonPressed(sender: UIButton) {
        
        reloadData()
    }
    
    // MARK: - Methods
    
    override func toggleEventList(show: Bool) {
        scheduleView.hidden = !show
    }
    
    override func toggleNoConnectivityMessage(show: Bool) {
        noConnectivityView.hidden = !show
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        
        
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
