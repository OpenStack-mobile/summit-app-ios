//
//  SearchViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/21/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

final class SearchViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: NSTableView!
    
    // MARK: - Properties
    
    
    
    // MARK: - Loading
    
    
    
    // MARK: - Actions
    
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    // MARK: - NSTableViewDelegate
    
    
}

// MARK: - Supporting Types

private extension SearchViewController
