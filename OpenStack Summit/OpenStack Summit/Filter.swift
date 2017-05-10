//
//  Filter.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreSummit
import CoreData

enum FilterCategory {
    
    /// ACTIVE TALKS
    case activeTalks
    
    /// CATEGORIES
    case trackGroup
    
    /// LEVEL
    case level
    
    /// VENUE
    case venue
}

enum Filter {
    
    /// Hide Past Talks
    case activeTalks
    
    case trackGroup(Identifier)
    case level(String)
    case venue(Identifier)
}

extension Filter: Hashable {
    
    var hashValue: Int {
        
        return "\(self)".hashValue
    }
}

func == (lhs: Filter, rhs: Filter) -> Bool {
    
    switch (lhs, rhs) {
        
    case (.activeTalks, .activeTalks): return true
    case let (.trackGroup(lhsValue), .trackGroup(rhsValue)): return lhsValue == rhsValue
    case let (.level(lhsValue), .level(rhsValue)): return lhsValue == rhsValue
    case let (.venue(lhsValue), .venue(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}

struct ScheduleFilter: Equatable {
    
    // MARK: - Properties
    
    /// Filters that have been enabled
    private(set) var activeFilters = Set<Filter>() {
        
        didSet {
            if oldValue.contains(.activeTalks) != activeFilters.contains(.activeTalks) {
                
                didChangeActiveTalks = true
            }
        }
    }
    
    /// All possible filters
    private(set) var allFilters = [FilterCategory: [Filter]]()
    
    /// Whether a selection has been made in the `Active Talks` filters.
    private(set) var didChangeActiveTalks = false
    
    // MARK: - Methods
    
    /// Updates the filter categories.
    /// Removes selections from deleted filters.
    mutating func update() {
        
        // reset valid filters
        allFilters.removeAll()
        
        // fetch current summit
        let context = Store.shared.managedObjectContext
        let summitID = SummitManager.shared.summit.value
        guard let summit = try! SummitManagedObject.find(summitID, context: context)
            else { activeFilters.removeAll(); return }
        
        // fetch data
        let trackGroups = try! TrackGroup.scheduled(for: summitID, context: context)
        let levels = try! Set(context.managedObjects(PresentationManagedObject.self, predicate: "event.summit.id" == summitID)
            .map({ $0.level ?? "" }))
            .filter({ $0 != "" })
            .sort()
        let venues = try! context.managedObjects(Venue.self, predicate: NSPredicate(format: "summit == %@", summit), sortDescriptors: VenueManagedObject.sortDescriptors)
        
        // populate filter categories
        
        let summitTimeZoneOffset = NSTimeZone(name: summit.timeZone)!.secondsFromGMT
        let startDate = summit.start.mt_dateSecondsAfter(summitTimeZoneOffset).mt_startOfCurrentDay()
        let endDate = summit.end.mt_dateSecondsAfter(summitTimeZoneOffset).mt_dateDaysAfter(1)
        let now = NSDate()
        
        if now.mt_isBetweenDate(startDate, andDate: endDate) {
            
            allFilters[.activeTalks] = [.activeTalks]
        }
        
        if trackGroups.isEmpty == false {
            
            allFilters[.trackGroup] = trackGroups.map { .trackGroup($0.identifier) }
        }
        
        if levels.isEmpty == false {
            
            allFilters[.level] = levels.map { .level($0) }
        }
        
        if venues.isEmpty == false {
            
            allFilters[.venue] = venues.map { .venue($0.identifier) }
        }
        
        // remove invalid active filters
        activeFilters = Set(activeFilters.filter { (filter) in allFilters.values.contains { $0.contains(filter) } })
        
        // automatically activate "Active Talks" filter if conditions apply.
        updateActiveTalks()
    }
    
    /// Updates the active talks selection.
    mutating func updateActiveTalks() {
        
        let context = Store.shared.managedObjectContext
        let summitID = SummitManager.shared.summit.value
        guard let summit = try! SummitManagedObject.find(summitID, context: context)
            else { return }
        
        let summitTimeZoneOffset = NSTimeZone(name: summit.timeZone)!.secondsFromGMT
        let startDate = summit.start.mt_dateSecondsAfter(summitTimeZoneOffset).mt_startOfCurrentDay()
        let endDate = summit.end.mt_dateSecondsAfter(summitTimeZoneOffset).mt_dateDaysAfter(1)
        let now = NSDate()
        
        if now.mt_isBetweenDate(startDate, andDate: endDate) {
            
            // dont want to override selection
            if didChangeActiveTalks == false {
                
                // During summit time jump to NOW as default, overriding Summit start date logic
                
                // start hiding active talks
                //activeFilters.insert(.activeTalks)
            }
        }
        else {
            
            // reset active talks selections if the summit has finished (or hasnt started)
            activeFilters.remove(.activeTalks)
        }
    }
    
    mutating func clear() {
        
        activeFilters.removeAll()
    }
    
    mutating func enable(filter newFilter: Filter) -> Bool {
        
        let validFilter = allFilters.values.contains { $0.contains(newFilter) }
        
        guard validFilter else { return false }
        
        activeFilters.insert(newFilter)
        
        return true
    }
    
    mutating func disable(filter filter: Filter) -> Bool {
        
        let validFilter = allFilters.values.contains { $0.contains(filter) }
        
        guard validFilter && activeFilters.contains(filter) else { return false }
        
        activeFilters.remove(filter)
        
        return true
    }
    
    // MARK: - Accessors
    
    /// Whether the schedule filter has active filters.
    var active: Bool {
        
        return activeFilters.isEmpty == false
    }
}

func == (lhs: ScheduleFilter, rhs: ScheduleFilter) -> Bool {
    
    let lhsFilters = lhs.allFilters.values.reduce([Filter](), combine: { $0.0 + $0.1 })
    let rhsFilters = rhs.allFilters.values.reduce([Filter](), combine: { $0.0 + $0.1 })
    
    return lhs.activeFilters == rhs.activeFilters
        && lhsFilters == rhsFilters
        && lhs.didChangeActiveTalks == rhs.didChangeActiveTalks
}

// MARK: - Manager

final class FilterManager {
    
    static let shared = FilterManager()
    
    var filter = Observable(ScheduleFilter())
    
    private var timer: NSTimer!
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private init() {
        
        // update sections from Core Data
        filter.value.update()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: NSManagedObjectContextObjectsDidChangeNotification,
            object: Store.shared.managedObjectContext)
        
        SummitManager.shared.summit.observe(currentSummitChanged)
    }
    
    @objc private func timerUpdate(sender: NSTimer) {
        
        filter.value.updateActiveTalks()
    }
    
    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        
        self.filter.value.update()
    }
    
    private func currentSummitChanged(summit: Identifier, oldValue: Identifier) {
        
        self.filter.value.update()
    }
}
