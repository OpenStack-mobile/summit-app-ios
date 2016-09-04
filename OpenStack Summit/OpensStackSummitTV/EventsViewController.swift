//
//  EventsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SwiftFoundation
import CoreSummit
import RealmSwift

final class EventsViewController: UITableViewController {
    
    // MARK: - Properties
    
    var state: State = .empty("Events", "No selection") {
        
        didSet {
            
            if isViewLoaded() {
                
                updateUI()
            }
        }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
}

// MARK: - Supporting Types

extension EventsViewController {
    
    enum State {
        
        // The view controller needs to configured.
        case empty(String, String)
        //case events(RealmRequest)
    }
}
