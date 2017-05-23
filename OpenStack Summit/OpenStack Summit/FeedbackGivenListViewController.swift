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
    
    @IBOutlet private(set) weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private(set) var feedbackList = [FeedbackDetail]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup table view
        tableView.register(R.nib.feedbackTableViewCell)
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        reloadData()
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        
        // Get Logged Member Given Feedback
        feedbackList = (Store.shared.authenticatedMember?.feedback ?? []).map { FeedbackDetail(managedObject: $0) }
        
        tableView.reloadData()
    }
    
    private func configure(cell: FeedbackTableViewCell, at indexPath: IndexPath) {
        
        let feedback = feedbackList[indexPath.row]
        cell.eventName = feedback.eventName
        cell.owner = feedback.member.name
        cell.rate = Double(feedback.rate)
        cell.review = feedback.review
        cell.date = feedback.date
        
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feedbackList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedbackTableViewCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Reviews")
    }
}
