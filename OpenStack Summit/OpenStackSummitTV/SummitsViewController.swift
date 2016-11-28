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
import SwiftSpinner

@objc(OSSTVSummitsViewController)
final class SummitsViewController: UITableViewController {
    
    typealias Summit = SummitsResponse.Summit
    
    // MARK: - Properties
    
    private(set) var summits = [Summit]() {
        
        didSet { didLoadSummits() }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 90
        
        self.refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
        
        self.navigationItem.title = "Loading..."
        
        Store.shared.summits { (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.navigationItem.title = "Summits"
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorAlert((error as NSError).localizedDescription, retryHandler: { controller.refresh() })
                    
                case let .Value(value):
                    
                    controller.summits = value.summits.sort { $0.0.start > $0.1.start }
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
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let summit = self[indexPath]
        
        cell.textLabel?.text = summit.name
    }
    
    private subscript (indexPath: NSIndexPath) -> Summit {
        
        return self.summits[indexPath.row]
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
        
        SummitManager.shared.summit.value = selectedSummit.identifier
        
        self.performSegueWithIdentifier(Segue.presentSummit.rawValue, sender: self)
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let segueIdentifier = Segue(rawValue: segue.identifier!)!
        
        switch segueIdentifier {
            
        case .presentSummit: break
        }
    }
}

private extension SummitsViewController {
    
    enum Segue: String {
        
        case presentSummit
    }
}
