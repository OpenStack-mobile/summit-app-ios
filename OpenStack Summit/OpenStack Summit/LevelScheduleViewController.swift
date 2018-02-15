//
//  LevelScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Foundation
import CoreSummit

final class LevelScheduleViewController: ScheduleViewController {
    
    // MARK: - Properties
    
    var level: Level!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(level != nil, "Level not set")
        
        self.title = level.rawValue.uppercased()
    }
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: Date, to endDate: Date) -> [Date] {
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let levels = [level!]
        var tracks = [Identifier]()
        var venues = [Identifier]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .track(identifier): tracks.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            default: break
            }
        }
        
        let date = DateFilter.interval(start: startDate, end: endDate)
        
        let events = try! EventManagedObject.filter(date, tracks: tracks, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
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
        
        let levels = [level!]
        var tracks = [Identifier]()
        var venues = [Identifier]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .track(identifier): tracks.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            default: break
            }
        }
        
        let events = try! EventManagedObject.filter(filter, tracks: tracks, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        return ScheduleItem.from(managedObjects: events)
    }
}
