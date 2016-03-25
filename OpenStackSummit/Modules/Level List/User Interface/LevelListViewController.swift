//
//  LevelListViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

@objc
public protocol ILevelListViewController: IMessageEnabledViewController {
    var searchTerm: String! { get set }
    var navigationController: UINavigationController? { get }
    
    func reloadData()
}

class LevelListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ILevelListViewController, IndicatorInfoProvider {
    var presenter: ILevelListPresenter!
    var searchTerm: String!
    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "levelTableViewCell"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewLoad()
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func reloadData() {
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
        return presenter.getLevelCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LevelTableViewCell
        presenter.buildScheduleCell(cell, index: indexPath.row)
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showLevelEvents(indexPath.row)
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Levels")
    }
}