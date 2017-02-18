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
        
        tableView.rowHeight = 50
        
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        refresh()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        tableView.tableColumns.first!.width = tableView.bounds.width
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func configure(cell cell: NSTableCellView, with summit: Summit) {
        
        cell.textField!.stringValue = summit.name
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
            
            let cell = tableView.makeViewWithIdentifier("SummitCell", owner: nil) as! NSTableCellView
            
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

