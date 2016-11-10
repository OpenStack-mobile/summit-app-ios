//
//  MyFeedbackViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit

final class FeedbackGivenListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageEnabledViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlet
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private(set) var feedbackList = [FeedbackDetail]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup table view
        tableView.registerNib(R.nib.feedbackTableViewCell)
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        reloadData()
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        
        // Get Logged Member Given Feedback
        feedbackList = (Store.shared.authenticatedMember?.givenFeedback ?? []).map { FeedbackDetail(managedObject: $0) }
        
        tableView.reloadData()
    }
    
    private func configure(cell cell: FeedbackTableViewCell, at indexPath: NSIndexPath) {
        
        let feedback = feedbackList[indexPath.row]
        cell.eventName = feedback.eventName
        cell.owner = feedback.owner
        cell.rate = Double(feedback.rate)
        cell.review = feedback.review
        cell.date = feedback.date
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feedbackList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.feedbackTableViewCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Reviews")
    }
}
