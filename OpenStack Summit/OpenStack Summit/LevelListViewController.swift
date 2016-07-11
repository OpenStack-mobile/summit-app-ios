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

final class LevelListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ScheduleFilterViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var searchTerm = ""
    
    var scheduleFilter = ScheduleFilter() {
        
        didSet { reloadData() }
    }
    
    // MARK: - Private Properties
    
    private var levels = [String]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBlankBackBarButtonItem()
        
        // setup table view
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        
        let levelsSet = Set(Store.shared.realm.objects(RealmPresentation).map({ $0.level }).filter({ $0.isEmpty == false }).sort())
        
        // remove duplicates
        self.levels = Array(levelsSet)
        
        if let levelSelections = scheduleFilter.selections[FilterSectionType.Level] as? [String] {
            if levelSelections.count > 0 {
                levels = levels.filter { levelSelections.contains($0) }
            }
        }
        
        self.tableView.reloadData()
    }
    
    private func configure(cell cell: LevelTableViewCell, at indexPath: NSIndexPath) {
        
        let level = levels[indexPath.row]
        cell.nameLabel.text = level
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return levels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.levelTableViewCell)!
        configure(cell: cell, at: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //self.presenter.showLevelEvents(indexPath.row)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Levels")
    }
}