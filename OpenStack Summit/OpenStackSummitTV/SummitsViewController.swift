//
//  SummitsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/25/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

@objc(OSSTVSummitsViewController)
final class SummitsViewController: UITableViewController {
    
    typealias Summit = SummitsResponse.Summit
    
    // MARK: - Properties
    
    private(set) var summits = [Summit]() {
        
        didSet { didLoadSummits() }
    }
    
    private(set) var loading = false {
        
        didSet { loadingChanged() }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 90
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
        
        self.loading = true
        
        Store.shared.summits { (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.loading = false
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorAlert((error as NSError).localizedDescription, retryHandler: { controller.refresh() })
                    
                case let .Value(value):
                    
                    controller.summits = value.items.sort { $0.0.start > $0.1.start }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func didLoadSummits() {
        
        self.tableView.reloadData()
    }
    
    @inline(__always)
    private func loadingChanged() {
        
        self.navigationItem.title = loading ? "Loading..." : "Summits"
        
        self.tableView.allowsSelection = loading == false
    }
    
    @inline(__always)
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let summit = self[indexPath]
        
        cell.textLabel?.text = summit.name
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: summit.timeZone.name)
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.stringFromDate(summit.start.toFoundation())
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.stringFromDate(summit.end.toFoundation())
        
        cell.detailTextLabel?.text = stringDateFrom + stringDateTo
    }
    
    private subscript (indexPath: NSIndexPath) -> Summit {
        
        return self.summits[indexPath.row]
    }
    
    private func select(summit identifier: Identifier) {
        
        SummitManager.shared.summit.value = identifier
        
        assert(self.currentSummit != nil, "Summit must already be loaded")
        
        self.performSegueWithIdentifier(Segue.presentSummit.rawValue, sender: self)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.summits.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SummitTableViewCell", forIndexPath: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedSummit = self[indexPath]
        
        if let _ = try! SummitManagedObject.find(selectedSummit.identifier, context: Store.shared.managedObjectContext) {
            
            self.select(summit: selectedSummit.identifier)
            
        } else {
            
            Store.shared.summit(selectedSummit.identifier) { [weak self] (response) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                    guard let controller = self else { return }
                    
                    switch response {
                        
                    case let .Error(error):
                        
                        controller.showErrorAlert((error as NSError).localizedDescription)
                        
                    case .Value:
                        
                        controller.select(summit: selectedSummit.identifier)
                    }
                }
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let segueIdentifier = Segue(rawValue: segue.identifier!)!
        
        switch segueIdentifier {
            
        case .presentSummit:
            
            break
        }
    }
}

private extension SummitsViewController {
    
    enum Segue: String {
        
        case presentSummit
    }
}
