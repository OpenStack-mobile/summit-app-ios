//
//  GeneralScheduleFilterViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 3/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import UIKit
import SwiftFoundation
import CoreSummit

final class GeneralScheduleFilterViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var filters: [(FilterCategory, [Filter])] = []
    
    private var filterObserver: Int?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup table view
        tableView.estimatedRowHeight = 48
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        // https://github.com/mac-cain13/R.swift/issues/144
        tableView.registerNib(R.nib.tableViewHeaderViewLight(), forHeaderFooterViewReuseIdentifier: TableViewHeaderView.resuseIdentifier)
        
        // observe filter
        filterObserver = FilterManager.shared.filter.observe { [weak self] _ in self?.configureView() }
        
        //  setup UI
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        FilterManager.shared.filter.value.update()
    }
    
    // MARK: - Actions
    
    @IBAction func filterChanged(sender: UISwitch) {
        
        let buttonOrigin = sender.convertPoint(.zero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(buttonOrigin)!
        let filter = self[indexPath]
        
        if sender.on {
            
            FilterManager.shared.filter.value.enable(filter: filter)
            
        } else {
            
            FilterManager.shared.filter.value.disable(filter: filter)
        }
    }
    
    @IBAction func dissmis(sender: AnyObject? = nil) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let scheduleFilter = FilterManager.shared.filter.value
        
        // load table data from current schedule filter
        filters = []
        
        
        
        
    }
    
    private subscript (indexPath: NSIndexPath) -> Filter {
        
        let (_, filters) = self.filters[indexPath.section]
        
        return filters[indexPath.row]
    }
    
    private func configure(cell cell: GeneralScheduleFilterTableViewCell, at indexPath: NSIndexPath) {
        
        let filter = self[indexPath]
        
        switch filter {
            
        case .activeTalks:
            
            cell.circleView.hidden = true
            cell.nameLabel.text =
        }
    }
    
    private func configure(header headerView: TableViewHeaderView, for section: Int) {
        
        let (filterCategory, _) = self.filters[section]
        
        let title: String
        
        switch filterCategory {
        case .activeTalks: title = "ACTIVE TALKS"
        case .trackGroup: title = "CATEGORIES"
        case .level: title = "LEVELS"
        case .venue: title = "VENUES"
        }
        
        header.titleLabel.text = title
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return filters.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let (_, filters) = self.filters[section]
        
        return filters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.generalScheduleFilterTableViewCell, forIndexPath: indexPath)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(TableViewHeaderView.resuseIdentifier)!
        
        configure(header: headerView, for: section)
        
        return headerView
    }
}

// MARK: - Supporting Types

private extension GeneralScheduleFilterViewController {
    
    struct Section {
        
        let category: FilterCategory
        let items: [Item]
    }
    
    struct Item {
        
        
    }
}

final class GeneralScheduleFilterTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var circleView: UIView!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var enabledSwitch: UISwitch!
}
