//
//  Filter.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit
import CoreData
import Predicate

enum FilterCategory {
    
    /// ACTIVE TALKS
    case activeTalks
    
    /// CATEGORIES
    case trackGroup
    
    /// TRACK
    case track
    
    /// LEVEL
    case level
    
    /// VENUE
    case venue
    
    /// ROOM
    case room
}

enum Filter {
    
    /// Hide Past Talks
    case activeTalks
    case video
    case track(Identifier)
    case trackGroup(Identifier)
    case level(Level)
    case venue(Identifier)
    case room(Identifier)
    
    public var identifier: Identifier? {
        
        switch self {
        case let .track(identifier): return identifier
        case let .trackGroup(identifier): return identifier
        case let .venue(identifier): return identifier
        case let .room(identifier): return identifier
        default: return nil
        }
    }
    
    public var category: FilterCategory {
        
        switch self {
        case .activeTalks: return .activeTalks
        case .video: return .activeTalks
        case .track: return .track
        case .trackGroup: return .trackGroup
        case .level: return .level
        case .venue: return .venue
        case .room: return .room
        }
    }
    
    public var parentCategory: FilterCategory? {
        
        switch self {
        case .track: return .trackGroup
        case .room: return .venue
        default: return nil
        }
    }
}

extension Filter: Hashable {
    
    var hashValue: Int {
        
        return "\(self)".hashValue
    }
}

func == (lhs: Filter, rhs: Filter) -> Bool {
    
    switch (lhs, rhs) {
        
    case (.activeTalks, .activeTalks): return true
    case (.video, .video): return true
    case let (.trackGroup(lhsValue), .trackGroup(rhsValue)): return lhsValue == rhsValue
    case let (.track(lhsValue), .track(rhsValue)): return lhsValue == rhsValue
    case let (.level(lhsValue), .level(rhsValue)): return lhsValue == rhsValue
    case let (.venue(lhsValue), .venue(rhsValue)): return lhsValue == rhsValue
    case let (.room(lhsValue), .room(rhsValue)): return lhsValue == rhsValue
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
        let tracks = try! Track.scheduled(for: summitID, context: context)
        
        let trackGroups = try! TrackGroup.scheduled(for: summitID, context: context)
        
        let levels = try! Set(context.managedObjects(PresentationManagedObject.self,
                                                     predicate: #keyPath(PresentationManagedObject.event.summit.id) == summitID)
            .flatMap { $0.level })
            .flatMap { Level(rawValue: $0) }
            .sorted()
        
        var rooms = [VenueRoom]()
        var venues = [Venue]()
        
        if let startShowingVenues = summit.startShowingVenues,
            NSDate().mt_is(after: startShowingVenues) {
            
            rooms = try! VenueRoom.scheduled(for: summitID, context: context)
            
            venues = try! context.managedObjects(Venue.self,
                                                     predicate: #keyPath(VenueManagedObject.summit.id) == summitID,
                                                     sortDescriptors: VenueManagedObject.sortDescriptors)
        }
        
        // populate filter categories
        
        let timeZone = TimeZone(identifier: summit.timeZone)!
        NSDate.mt_setTimeZone(timeZone)
        
        let startDate = (summit.start as NSDate).mt_startOfCurrentDay()
        let endDate = (summit.end as NSDate).mt_startOfNextDay()
        let now = Date()
        
        allFilters[.activeTalks] = []
        
        if (now as NSDate).mt_isBetweenDate(startDate, andDate: endDate) {
            
            allFilters[.activeTalks]?.append(.activeTalks)
        }
        
        allFilters[.activeTalks]?.append(.video)
        
        if tracks.isEmpty == false {
            
            allFilters[.track] = tracks.map { .track($0.identifier) }
        }
        
        if trackGroups.isEmpty == false {
            
            allFilters[.trackGroup] = trackGroups.map { .trackGroup($0.identifier) }
        }
        
        if levels.isEmpty == false {
            
            allFilters[.level] = levels.map { .level($0) }
        }
        
        if rooms.isEmpty == false {
            
            allFilters[.room] = rooms.map { .room($0.identifier) }
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
        
        let timeZone = TimeZone(identifier: summit.timeZone)!
        NSDate.mt_setTimeZone(timeZone)
        
        let startDate = (summit.start as NSDate).mt_startOfCurrentDay()
        let endDate = (summit.end as NSDate).mt_startOfNextDay()
        let now = Date()
        
        if (now as NSDate).mt_isBetweenDate(startDate, andDate: endDate) {
            
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
    
    @discardableResult
    mutating func enable(_ filter: Filter) -> Bool {
        
        let validFilter = allFilters.values.contains { $0.contains(filter) }
        
        guard validFilter else { return false }
        
        activeFilters.insert(filter)
        
        return true
    }
    
    @discardableResult
    mutating func disable(_ filter: Filter) -> Bool {
        
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
    
    let lhsFilters = lhs.allFilters.values.reduce([Filter](), { $0 + $1 })
    let rhsFilters = rhs.allFilters.values.reduce([Filter](), { $0 + $1 })
    
    return lhs.activeFilters == rhs.activeFilters
        && lhsFilters == rhsFilters
        && lhs.didChangeActiveTalks == rhs.didChangeActiveTalks
}

// MARK: - Manager

final class FilterManager {
    
    static let shared = FilterManager()
    
    var filter = Observable(ScheduleFilter())
    
    private var timer: Timer!
    
    private var summitObserver: Int!
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
        SummitManager.shared.summit.remove(summitObserver)
    }
    
    private init() {
        
        // update sections from Core Data
        self.filter.value.update()
        
        self.timer = Timer.scheduledTimer(timeInterval: 10,
                                     target: self,
                                     selector: #selector(timerUpdate),
                                     userInfo: nil,
                                     repeats: true)
        
        self.summitObserver = SummitManager.shared.summit.observe(currentSummitChanged)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: Store.shared.managedObjectContext)
    }
    
    @objc private func timerUpdate(_ sender: Timer) {
        
        filter.value.updateActiveTalks()
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Foundation.Notification) {
        
        self.filter.value.update()
    }
    
    private func currentSummitChanged(_ summit: Identifier, oldValue: Identifier) {
        
        self.filter.value.update()
    }
}
