//
//  Filter.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit
import CoreData

enum FilterSectionType {
    
    case ActiveTalks, Track, TrackGroup, Tag, Level, Venue
}

struct FilterSection: Equatable {
    var type: FilterSectionType
    var name: String
    var items: [FilterSectionItem]
    
    private init(type: FilterSectionType, name: String, items: [FilterSectionItem] = []) {
        
        self.type = type
        self.name = name
        self.items = items
    }
}

func == (lhs: FilterSection, rhs: FilterSection) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.name == rhs.name
        && lhs.items == rhs.items
}

struct FilterSectionItem: Unique, Named, Equatable {
    
    let identifier: Identifier
    let name: String
}

func == (lhs: FilterSectionItem, rhs: FilterSectionItem) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
}

enum FilterSelection: RawRepresentable, Equatable {
    
    case identifiers([Identifier])
    case names([String])
    
    init?(rawValue: [AnyObject]) {
        
        if let identifiers = (rawValue as? [NSNumber]) as? [Int] {
            
            self = .identifiers(identifiers)
            return
        }
        
        if let names = rawValue as? [NSString] {
            
            self = .names(names.map { String($0) })
            return
        }
        
        return nil
    }
    
    var rawValue: [AnyObject] {
        
        switch self {
        case let .identifiers(rawValue): return rawValue as [NSNumber]
        case let .names(rawValue): return rawValue as [NSString]
        }
    }
    
    var isEmpty: Bool {
        
        return rawValue.isEmpty
    }
    
    mutating func removeAll() {
        
        switch self {
        case .identifiers: self = .identifiers([])
        case .names: self = .names([])
        }
    }
    
    mutating func removeAtIndex(index: Int) {
        
        switch self {
        case var .identifiers(rawValue):
            
            rawValue.removeAtIndex(index)
            self = .identifiers(rawValue)
            
        case var .names(rawValue):
            
            rawValue.removeAtIndex(index)
            self = .names(rawValue)
        }
    }
    
    mutating func append(newElement: Identifier) {
        
        switch self {
        case var .identifiers(rawValue):
            
            rawValue.append(newElement)
            self = .identifiers(rawValue)
            
        default: fatalError("Appending invalid type")
        }
    }
    
    mutating func append(newElement: String) {
        
        switch self {
        case var .names(rawValue):
            
            rawValue.append(newElement)
            self = .names(rawValue)
            
        default: fatalError("Appending invalid type")
        }
    }
    
    /// Updates the current filter selection by removing selections that are not availible anymore.
    ///
    /// - Parameter newItems: All the possible selections this `FilterSelection` can support. 
    /// If an item is currently selected and not avalible in the new list of selections then it will be removed.
    ///
    /// - Note: The `newItems` case must match the case of the `FilterSelection`. Otherwise, an exception is thrown.
    mutating func update(newItems: FilterSelection) {
        
        switch (self, newItems) {
    
        case (let .identifiers(existing), let .identifiers(new)):
            
            let filteredSelection = existing.filter { new.contains($0) }
            
            self = .identifiers(filteredSelection)
            
        case (let .names(existing), let .names(new)):
            
            let filteredSelection = existing.filter { new.contains($0) }
            
            self = .names(filteredSelection)
            
        default: fatalError("New items type mismatch, can only filter with the same type of FilterSelection")
        }
    }
}

func == (lhs: FilterSelection, rhs: FilterSelection) -> Bool {
    
    switch (lhs, rhs) {
    case let (.identifiers(lhsValues), .identifiers(rhsValues)): return lhsValues == rhsValues
    case let (.names(lhsValues), .names(rhsValues)): return lhsValues == rhsValues
    default: return false
    }
}

struct ScheduleFilter: Equatable {
    
    // MARK: - Properties
    
    var selections = [FilterSectionType: FilterSelection]() {
        
        didSet {
            
            var oldFilter = self
            oldFilter.selections = oldValue
            let wasHidingPastTalks = oldFilter.shoudHidePastTalks()
            
            if shoudHidePastTalks() != wasHidingPastTalks {
                
                didChangeActiveTalks = true
            }
        }
    }
    var filterSections = [FilterSection]()
    
    /// Whether a selection has been made in the `Active Talks` filters.
    private(set) var didChangeActiveTalks = false
    
    // MARK: - Initialization
    
    init() {
        
        // setup empty selections
        selections[FilterSectionType.ActiveTalks] = .names([])
        selections[FilterSectionType.TrackGroup] = .identifiers([])
        selections[FilterSectionType.Level] = .names([])
        selections[FilterSectionType.Tag] = .names([])
        selections[FilterSectionType.Venue] = .identifiers([])
    }
    
    // MARK: - Methods
    
    /// Updates the filter sections.
    /// Removes selections from deleted filters.
    mutating func updateSections() {
        
        filterSections = []
        
        let context = Store.shared.managedObjectContext
        let summitID = SummitManager.shared.summit.value
        guard let summit = try! SummitManagedObject.find(summitID, context: context)
            else { return }
        
        let summitTrackGroups = try! TrackGroup.scheduled(for: summitID, context: context)
        let levels = try! Set(context.managedObjects(PresentationManagedObject).map({ $0.level ?? "" })).filter({ $0 != "" }).sort()
        let venues = try! context.managedObjects(Venue.self, predicate: NSPredicate(format: "summit == %@", summit), sortDescriptors: VenueManagedObject.sortDescriptors)
        
        var filterSection: FilterSection
        
        filterSection = FilterSection(type: .ActiveTalks, name: "ACTIVE TALKS")
        let activeTalksFilters = ["Hide Past Talks"]
        
        let summitTimeZoneOffset = NSTimeZone(name: summit.timeZone)!.secondsFromGMT
        
        let startDate = summit.start.mt_dateSecondsAfter(summitTimeZoneOffset).mt_startOfCurrentDay()
        let endDate = summit.end.mt_dateSecondsAfter(summitTimeZoneOffset).mt_dateDaysAfter(1)
        let now = NSDate()
        
        if now.mt_isBetweenDate(startDate, andDate: endDate) {
            
            filterSection.items = activeTalksFilters.map { FilterSectionItem(identifier: 0, name: $0) }
        }
        else {
            
            filterSection.items = []
        }
        
        filterSections.append(filterSection)
        
        filterSection = FilterSection(type: .TrackGroup, name: "SUMMIT CATEGORY")
        filterSection.items = summitTrackGroups.map { FilterSectionItem(identifier: $0.identifier, name: $0.name) }
        selections[FilterSectionType.TrackGroup]?.update(.identifiers(summitTrackGroups.identifiers))
        
        filterSections.append(filterSection)
        
        filterSection = FilterSection(type: .Level, name: "LEVEL")
        filterSection.items = levels.map { FilterSectionItem(identifier: 0, name: $0) }
        selections[FilterSectionType.Level]?.update(.names(levels))
        
        filterSections.append(filterSection)
        
        filterSection = FilterSection(type: .Venue, name: "VENUE")
        filterSection.items = venues.map { FilterSectionItem(identifier: $0.identifier, name: $0.name) }
        selections[FilterSectionType.Venue]?.update(.identifiers(venues.identifiers))
        
        filterSections.append(filterSection)
        
        updateActiveTalksSelections()
    }
    
    /// Updates the active talks selections
    mutating func updateActiveTalksSelections() {
        
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
                
                // start hiding active talks
                selections[FilterSectionType.ActiveTalks] = .names(["Hide Past Talks"])
            }
        }
        else {
            
            // reset active talks selections if the summit has finished (or hasnt started)
            selections[FilterSectionType.ActiveTalks] = .names([])
        }
    }
    
    func areAllSelectedForType(type: FilterSectionType) -> Bool {
        if (filterSections.count == 0) {
            return false
        }
        let filterSection = filterSections.filter() { $0.type == type }.first!
        return filterSection.items.count == selections[type]?.rawValue.count
    }
    
    func hasActiveFilters() -> Bool {
        
        for values in selections.values {
            
            if values.rawValue.count > 0 {
                
                return true
            }
        }
        
        return false
    }
    
    mutating func clearActiveFilters() {
        for key in selections.keys {
            selections[key]?.removeAll()
        }
    }
    
    func shoudHidePastTalks() -> Bool {
        var hidePastTalks = false
        
        if let activeTalks = selections[FilterSectionType.ActiveTalks]?.rawValue as? [String] {
            if activeTalks.contains("Hide Past Talks") {
                hidePastTalks = true
            }
        }
        
        return hidePastTalks
    }
}

func == (lhs: ScheduleFilter, rhs: ScheduleFilter) -> Bool {
    
    return lhs.selections == rhs.selections
        && lhs.filterSections == rhs.filterSections
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
        
        // update sections from Realm
        filter.value.updateSections()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: NSManagedObjectContextObjectsDidChangeNotification,
            object: Store.shared.managedObjectContext)
        
        SummitManager.shared.summit.observe(currentSummitChanged)
    }
    
    @objc private func timerUpdate(sender: NSTimer) {
        
        filter.value.updateActiveTalksSelections()
    }
    
    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        
        self.filter.value.updateSections()
    }
    
    private func currentSummitChanged(summit: Identifier) {
        
        self.filter.value.updateSections()
    }
}
