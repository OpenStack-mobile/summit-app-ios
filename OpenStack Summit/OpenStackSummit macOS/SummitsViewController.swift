//
//  ViewController.swift
//  Summit
//
//  Created by Alsey Coleman Miller on 2/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Cocoa
import CoreSummit

final class SummitsViewController: NSViewController, PagingTableViewController {
    
    typealias Summit = SummitsResponse.Summit
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: NSTableView!
    
    @IBOutlet private(set) weak var activityIndicator: NSProgressIndicator!
    
    // MARK: - Properties
    
    lazy var pageController = PageController<Summit>(fetch: Store.shared.summits)
    
    // MARK: - Loading

    override func viewDidLoad() {
        super.viewDidLoad()
                
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        refresh()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        tableView.tableColumns.first!.maxWidth = tableView.bounds.width
        tableView.tableColumns.first!.width = tableView.bounds.width
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    @IBAction func tableViewDoubleClick(sender: AnyObject) {
        
        guard tableView.selectedRow >= 0,
            case let .item(item) = pageController.items[tableView.selectedRow]
            else { return }
        
        // set summit
        SummitManager.shared.summit.value = item.identifier
        
        // show view controller
        self.performSegueWithIdentifier("showSummit", sender: nil)
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func configure(cell cell: SummitTableViewCell, with summit: Summit) {
        
        cell.nameLabel!.stringValue = summit.name
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: summit.timeZone.name)
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.stringFromDate(summit.start.toFoundation())
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.stringFromDate(summit.end.toFoundation())
        
        cell.dateLabel!.stringValue = stringDateFrom + stringDateTo
    }
    
    // MARK: - ShowActivityIndicatorProtocol
    
    func showActivityIndicator() {
        
        activityIndicator.hidden = false
        activityIndicator.startAnimation(nil)
    }
    
    func hideActivityIndicator() {
        
        activityIndicator.hidden = true
        activityIndicator.stopAnimation(nil)
    }

    // MARK: - NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        return pageController.items.count
    }
    
    func tableView(tableView: NSTableView, numberOfRowsInSection section: Int) -> Int {
        
        return pageController.items.count
    }
    
    // MARK: - NSTableViewDelegate
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let data = pageController.items[row]
        
        switch data {
            
        case let .item(item):
            
            let cell = tableView.makeViewWithIdentifier(SummitTableViewCell.identifier, owner: nil) as! SummitTableViewCell
            
            configure(cell: cell, with: item)
            
            return cell
            
        case .loading:
            
            pageController.loadNextPage()
            
            let cell = NSTableCellView()
            
            cell.textField?.stringValue = "Loading..."
            
            return cell
        }
    }
}

// MARK: - Supporting Types

final class SummitTableViewCell: NSTableCellView {
    
    static let identifier = "SummitTableViewCell"
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var dateLabel: NSTextField!
}

