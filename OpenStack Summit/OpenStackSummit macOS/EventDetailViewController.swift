//
//  EventDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

final class EventDetailViewController: NSViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var trackLabel: NSTextField!
    
    // MARK: - Properties
    
    var event: Identifier? {
        
        didSet { didSetEvent() }
    }
    
    var entityController: EntityController<EventDetail>?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Private Methods
    
    private func didSetEvent() {
        
        if let event = self.event {
            
            let entityController = EntityController<EventDetail>(identifier: event,
                                                                 entity: EventManagedObject.self,
                                                                 context: Store.shared.managedObjectContext)
            
            entityController.event.updated = { [weak self] in self?.configureView($0) }
            
            entityController.event.deleted = { [weak self] _ in self?.view.window?.close() }
            
            entityController.enabled = true
            
            self.entityController = entityController
            
        } else {
            
            entityController = nil
        }
    }
    
    private func configureView(event: EventDetail) {
        
        self.nameLabel.stringValue = event.name
        self.trackLabel.stringValue = event.track
    }
}
