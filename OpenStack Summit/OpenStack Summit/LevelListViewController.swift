//
//  LevelListViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit
import RealmSwift

final class LevelListViewController: UIViewController, BaseViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var searchTerm = ""
    
    // MARK: - Private Properties
    
    private var scheduleFilter = ScheduleFilter()
    
    private var levels = [String]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBlankBackBarButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        reloadData()
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        
        var levels = Store.shared.realm.objects(RealmPresentation).map({ $0.level }).sort()
        
        if let levelSelections = scheduleFilter.selections[FilterSectionType.Level] as? [String] {
            if levelSelections.count > 0 {
                levels = levels.filter { levelSelections.contains($0) }
            }
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
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
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.presenter.showLevelEvents(indexPath.row)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Levels")
    }
}