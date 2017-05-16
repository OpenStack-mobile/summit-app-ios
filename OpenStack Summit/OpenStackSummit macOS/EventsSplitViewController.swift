//
//  EventsSplitViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreSummit
import Predicate

final class EventsSplitViewController: NSSplitViewController, SearchableController, EventDatesViewControllerDelegate {
    
    // MARK: - Properties
    
    var searchTerm = "" {
        
        didSet { configureView() }
    }
    
    private(set) var selectedDate: Date? {
        
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
        
        let predicate: Predicate
        
        if searchTerm.isEmpty == false {
            
            // show events for search term
            
            //predicate = NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
            predicate = (#keyPath(EventManagedObject.name)).compare(.contains, [.caseInsensitive], .value(.string(searchTerm)))
            
        } else if let selectedDate = self.selectedDate  {
            
            // show events for date
            
            let endDate = (selectedDate as NSDate).mt_endOfCurrentDay()!
            
            //predicate = NSPredicate(format: "start >= %@ AND end <= %@", selectedDate as NSDate, endDate as NSDate)
            predicate = #keyPath(EventManagedObject.start) >= selectedDate
                && #keyPath(EventManagedObject.end) <= endDate
            
        } else {
            
            // show no events
            predicate = .value(false)
        }
        
        let collapseSidebar = searchTerm.isEmpty == false
        
        // collapse sidebar
        if collapseSidebar != splitViewItems[0].isCollapsed {
            
            splitViewItems[0].canCollapse = true
            splitViewItems[0].animator().isCollapsed = collapseSidebar
            splitViewItems[0].canCollapse = false
        }
        
        eventsViewController.predicate = predicate
    }
    
    // MARK: - EventDatesViewControllerDelegate
    
    func eventDatesViewController(_ controller: EventDatesViewController, didSelect selectedDate: Date) {
        
        self.selectedDate = selectedDate
    }
}

