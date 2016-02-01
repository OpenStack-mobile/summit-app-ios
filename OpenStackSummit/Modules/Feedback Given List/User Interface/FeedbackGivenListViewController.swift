//
//  MyFeedbackViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

@objc
public protocol IFeedbackGivenListViewController: IMessageEnabledViewController {
    func releoadList()
}

class FeedbackGivenListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IFeedbackGivenListViewController, IndicatorInfoProvider {
    
    let cellIdentifier = "feedbackTableViewCell"
    @IBOutlet weak var tableView: UITableView!
    var presenter : IFeedbackGivenListPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "FeedbackTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        presenter.viewLoad()
    }
    
    func releoadList() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getFeedbackCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FeedbackTableViewCell
        presenter.buildFeedbackCell(cell, index: indexPath.row)
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Feedback")
    }
}
