//
//  EventsSplitViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit

final class EventsSplitViewController: NSSplitViewController, SearchableController, EventDatesViewControllerDelegate {
    
    // MARK: - Properties
    
    var searchTerm = "" {
        
        didSet { configureView() }
    }
    
    private(set) var selectedDate: NSDate? {
        
        didSet { configureView() }
    }
    
    var eventDatesViewController: EventDatesViewController {
        
        return childViewControllers[0] as! EventDatesViewController
    }
    
    var eventsViewController: EventsViewController {
        
        return childViewControllers[1] as! EventsViewController
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventDatesViewController.delegate = self
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let predicate: NSPredicate
        
        if searchTerm.isEmpty == false {
            
            // show events for search term
            
            predicate = NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
            
        } else if let selectedDate = self.selectedDate  {
            
            // show events for date
            
            let endDate = selectedDate.mt_endOfCurrentDay()
            
            predicate = NSPredicate(format: "start >= %@ AND end <= %@", selectedDate, endDate)
            
        } else {
            
            // show no events
            predicate = NSPredicate(value: false)
        }
        
        let collapseSidebar = searchTerm.isEmpty == false
        
        // collapse sidebar
        if collapseSidebar != splitViewItems[0].collapsed {
            
            splitViewItems[0].canCollapse = true
            splitViewItems[0].animator().collapsed = collapseSidebar
            splitViewItems[0].canCollapse = false
        }
        
        eventsViewController.predicate = predicate
    }
    
    // MARK: - EventDatesViewControllerDelegate
    
    func eventDatesViewController(controller: EventDatesViewController, didSelect selectedDate: NSDate) {
        
        self.selectedDate = selectedDate
    }
}

