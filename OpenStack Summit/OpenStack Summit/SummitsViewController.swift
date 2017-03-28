//
//  SummitsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/26/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit
import JGProgressHUD

final class SummitsViewController: UITableViewController, PagingTableViewController {
    
    typealias Summit = SummitsResponse.Summit
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var doneButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    var didFinish: ((SummitsViewController) -> ())? {
        
        didSet { configureView() }
    }
    
    lazy var pageController: PageController<Summit> = PageController(fetch: Store.shared.summits)
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .Dark)
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(R.nib.loadingTableViewCell)
        
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        refresh()
        
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.bringSubviewToFront(progressHUD)
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    @IBAction func done(sender: AnyObject? = nil) {
        
        self.didFinish?(self)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        self.navigationItem.rightBarButtonItem = didFinish != nil ? doneButton : nil
    }
    
    private func configure(cell cell: UITableViewCell, with summit: Summit) {
        
        cell.textLabel!.text = summit.name
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: summit.timeZone.name)
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.stringFromDate(summit.start.toFoundation())
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.stringFromDate(summit.end.toFoundation())
        
        cell.detailTextLabel!.text = stringDateFrom + stringDateTo
        
        let isCurrentSummit = SummitManager.shared.summit.value == summit.identifier
        
        cell.accessoryType = isCurrentSummit ? .Checkmark : .None
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pageController.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = self.pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(item):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.summitCell, forIndexPath: indexPath)!
            
            configure(cell: cell, with: item)
            
            return cell
            
        case .loading:
            
            pageController.loadNextPage()
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.loadingTableViewCell, forIndexPath: indexPath)!
            
            cell.activityIndicator.hidden = false
            
            cell.activityIndicator.startAnimating()
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let data = self.pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(summit):
            
            SummitManager.shared.summit.value = summit.identifier
            
            self.tableView.reloadData()
            
        case .loading: break
        }
    }
}
