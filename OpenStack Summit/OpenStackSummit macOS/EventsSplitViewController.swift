//
//  EventsSplitViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit

final class EventsSplitViewController: NSSplitViewController, EventDatesViewControllerDelegate {
    
    // MARK: - Properties
    
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
    
    // MARK: - EventDatesViewControllerDelegate
    
    func eventDatesViewController(controller: EventDatesViewController, didSelect selectedDate: NSDate) {
        
        let endDate = selectedDate.mt_endOfCurrentDay()
        
        let predicate = NSPredicate(format: "start >= %@ AND end <= %@", selectedDate, endDate)
        
        eventsViewController.predicate = predicate
    }
}

