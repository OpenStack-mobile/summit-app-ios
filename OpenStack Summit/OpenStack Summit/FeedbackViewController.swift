//
//  FeedbackViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 3/29/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftFoundation
import CoreSummit

final class FeedbackViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    // MARK: - Properties
    
    var content: Content! {
        
        didSet { if isViewLoaded() { configureView() } }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(content != nil)
        
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        switch self.content! {
            
        case let .new(eventID):
            
            guard let eventManagedObject = try! EventManagedObject.find(eventID, context: Store.shared.managedObjectContext)
                else { fatalError("Invalid event \(eventID)") }
            
            let event = Event(managedObject: eventManagedObject)
            
            configureView(with: event)
            
        case let .edit(feedbackID):
            
            guard let feedbackManagedObject = try! FeedbackManagedObject.find(feedbackID, context: Store.shared.managedObjectContext)
                else { fatalError("Invalid feedback \(feedbackID)") }
            
            let feedback = Feedback(managedObject: feedbackManagedObject)
            
            let event = Event(managedObject: feedbackManagedObject.event)
            
            configureView(with: event, feedback: feedback)
        }
    }
    
    private func configureView(with event: Event, feedback: Feedback? = nil) {
        
        
    }
}

// MARK: - Supporting Files

extension FeedbackViewController {
    
    enum Content {
        
        case new(event: Identifier)
        case edit(feedback: Identifier)
    }
}
