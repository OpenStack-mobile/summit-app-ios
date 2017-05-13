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
        var trackGroups = [Identifier]()
        var venues = [Identifier]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .trackGroup(identifier): trackGroups.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            case .level: break
            case .activeTalks: break
            }
        }
        
        let date = DateFilter.interval(start: startDate, end: endDate)
        
        let events = try! EventManagedObject.filter(date, trackGroups: trackGroups, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        var activeDates: [Date] = []
        for event in events {
            let timeZone = TimeZone(identifier: event.summit.timeZone)!
            let startDate = ((event.start as NSDate).mt_dateSeconds(after: timeZone.secondsFromGMT()) as NSDate).mt_startOfCurrentDay()!
            if !activeDates.contains(startDate) {
                activeDates.append(startDate)
            }
            
        }
        return activeDates
    }
    
    override func scheduledEvents(_ filter: DateFilter) -> [ScheduleItem] {
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let levels = [level!]
        var trackGroups = [Identifier]()
        var venues = [Identifier]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .trackGroup(identifier): trackGroups.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            case .level: break
            case .activeTalks: break
            }
        }
        
        let events = try! EventManagedObject.filter(filter, trackGroups: trackGroups, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        return ScheduleItem.from(managedObjects: events)
    }
}
