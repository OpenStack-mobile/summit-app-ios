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
        
        eventsViewController.tableView.selectionHighlightStyle = .Regular
        
        configureView()
    }
    
    // MARK: - Private Methods
        
    private func configureView() {
        
        if let speaker = self.speaker {
            
            // configure child view controllers
            
            memberProfileViewController.profile = .speaker(speaker)
            
            let speakerID = NSNumber(longLong: Int64(speaker))
            
            let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
            
            eventsViewController.predicate = NSPredicate(format: "ANY presentation.speakers.id == %@ && summit.id == %@", speakerID, summitID)
            
        } else {
            
            memberProfileViewController.profile = .currentUser
            
            eventsViewController.predicate = NSPredicate(value: false)
        }
    }
}
