//
//  SpeakerViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

final class SpeakerViewController: NSSplitViewController {
    
    // MARK: - Properties
    
    var speaker: Identifier!
    
    private var entityController: EntityController<Speaker>!
    
    // MARK: - Properties
    
    var memberProfileViewController: MemberProfileViewController {
        
        return childViewControllers[0] as! MemberProfileViewController
    }
    
    var eventsViewController: EventsViewController {
        
        return childViewControllers[1] as! EventsViewController
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(speaker, "Did not set speaker")
        
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        // configure child view controllers
        
        memberProfileViewController.profile = .speaker(speaker)
        
        eventsViewController.predicate = NSPredicate()
        
        // obserb
        entityController = EntityController(identifier: speaker,
                                            entity: SpeakerManagedObject.self,
                                            context: Store.shared.managedObjectContext)
        
        entityController.event.updated = { [weak self] _ in self?.configureView() }
        
        entityController.event.deleted = { [weak self] _ in self?.configureView() }
        
        ")
    }
    
    private func updateUI() {
        
        
    }
}
