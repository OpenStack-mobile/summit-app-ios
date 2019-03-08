//
//  TrackScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Foundation
import CoreSummit

final class TrackScheduleViewController: ScheduleViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var trackLabel: UILabel!
    
    // MARK: - Properties
    
    var track: Track!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(track != nil, "No track set")
        
        navigationItem.title = "TRACK"
        self.scheduleView.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        trackLabel.text = track.name
    }
    
    // MARK: - Methods
    
    override func scheduleActiveDates(from startDate: Date, to endDate: Date) -> [Date] {
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let tracks = [self.track.identifier]
        var rooms = [Identifier]()
        var venues = [Identifier]()
        var levels = [Level]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .room(identifier): rooms.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            case let .level(level): levels.append(level)
            default: break
            }
        }
        
        let date = DateFilter.interval(start: startDate, end: endDate)
        
        let events = try! EventManagedObject.filter(date, tracks: tracks, levels: levels, rooms: rooms, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        var activeDates: [Date] = []
        
        for event in events {
            
            // no need to do timeZone adjustments
            // NSDate.mt_setTimeZone(timeZone) set on base class alters mt_startOfCurrentDay() calculation
            
            let date = (event.start as NSDate).mt_startOfCurrentDay()!
            
            if !activeDates.contains(date) {
                
                activeDates.append(date)
            }
        }
        
        return activeDates
    }
    
    override func scheduledEvents(_ filter: DateFilter) -> [ScheduleItem] {
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let tracks = [self.track.identifier]
        var rooms = [Identifier]()
        var venues = [Identifier]()
        var levels = [Level]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .room(identifier): rooms.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            case let .level(level): levels.append(level)
            default: break
            }
        }
        
        let events = try! EventManagedObject.filter(filter, tracks: tracks, levels: levels, rooms: rooms, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        return ScheduleItem.from(managedObjects: events)
    }
}
