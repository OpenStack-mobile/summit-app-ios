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
import Predicate

final class SpeakerViewController: NSViewController {
    
    // MARK: - Properties
    
    var speaker: Identifier? {
        
        didSet { configureView() }
    }
    
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
        
        eventsViewController.tableView.selectionHighlightStyle = .regular
        
        configureView()
    }
    
    // MARK: - Private Methods
        
    private func configureView() {
        
        if let speaker = self.speaker {
            
            // configure child view controllers
            
            memberProfileViewController.profile = .speaker(speaker)
            
            //eventsViewController.predicate = NSPredicate(format: "ANY presentation.speakers.id == %@ && summit.id == %@", speakerID, summitID)
            eventsViewController.predicate = (#keyPath(EventManagedObject.presentation.speakers.id)).any(in: [speaker])
            && #keyPath(EventManagedObject.summit.id) == SummitManager.shared.summit.value
            
        } else {
            
            memberProfileViewController.profile = .currentUser
            
            eventsViewController.predicate = .value(false)
        }
    }
}
