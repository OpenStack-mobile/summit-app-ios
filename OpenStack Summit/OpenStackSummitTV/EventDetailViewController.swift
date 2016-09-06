//
//  EventDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/5/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

final class EventDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IB Outlets 
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var event: Identifier!
    
    private var eventDetail: EventDetail!
    
    private var data = [Detail]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        assert(event != nil, "No identifier set")
        
        guard let realmEvent = RealmSummitEvent.find(event, realm: Store.shared.realm)
            else { fatalError("Invalid event \(event)") }
        
        self.eventDetail = EventDetail(realmEntity: realmEvent)
        
        self.data = [Detail]()
        
        data.append(.name(eventDetail.name))
        
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let detail = self.data[indexPath.row]
        
        switch detail {
            
        case let .name(name):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventNameCell", forIndexPath: indexPath)
            
            cell.textLabel!.text = name
            
            return cell
        }
    }
}

// MARK: - Supporting Types

private extension EventDetailViewController {
    
    enum Detail {
        
        case name(String)
        
    }
}
