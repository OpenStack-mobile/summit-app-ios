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

final class EventDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    var event: Identifier!
    
    private var eventDetail: EventDetail!
    
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
        
        self.title = eventDetail.name
        
        
    }
}
