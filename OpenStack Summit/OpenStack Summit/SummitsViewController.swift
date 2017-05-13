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
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.loadingTableViewCell)
        
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        refresh()
        
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.bringSubview(toFront: progressHUD)
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(_ sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    @IBAction func done(_ sender: AnyObject? = nil) {
        
        self.didFinish?(self)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        self.navigationItem.rightBarButtonItem = didFinish != nil ? doneButton : nil
    }
    
    private func configure(cell: UITableViewCell, with summit: Summit) {
        
        cell.textLabel!.text = summit.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: summit.timeZone.name)
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.string(from: summit.start)
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.string(from: summit.end)
        
        cell.detailTextLabel!.text = stringDateFrom + stringDateTo
        
        let isCurrentSummit = SummitManager.shared.summit.value == summit.identifier
        
        cell.accessoryType = isCurrentSummit ? .checkmark : .none
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pageController.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = self.pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(item):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.summitCell, for: indexPath)!
            
            configure(cell: cell, with: item)
            
            return cell
            
        case .loading:
            
            pageController.loadNextPage()
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.loadingTableViewCell, for: indexPath)!
            
            cell.activityIndicator.isHidden = false
            
            cell.activityIndicator.startAnimating()
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = self.pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(summit):
            
            SummitManager.shared.summit.value = summit.identifier
            
            self.tableView.reloadData()
            
        case .loading: break
        }
    }
}
