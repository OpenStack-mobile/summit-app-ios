//
//  Filter.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit
import RealmSwift

enum FilterSectionType {
    
    case ActiveTalks, EventType, Track, TrackGroup, Tag, Level, Venue
}

struct FilterSection {
    var type: FilterSectionType
    var name: String
    var items: [FilterSectionItem]
    
    private init(type: FilterSectionType, name: String, items: [FilterSectionItem] = []) {
        
        self.type = type
        self.name = name
        self.items = items
    }
}

struct FilterSectionItem: Unique, Named {
    
    let identifier: Identifier
    let name: String
}

enum FilterSelection: RawRepresentable {
    
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

struct ScheduleFilter {
    
    // MARK: - Properties
    
    var selections = [FilterSectionType: FilterSelection]()
    var filterSections = [FilterSection]()
    
    /// Whether a selection has been made in the `Active Talks` filters.
    var didChangeActiveTalks = false
    
    // MARK: - Initialization
    
    init() {
        
        // setup empty selections
        selections[FilterSectionType.ActiveTalks] = .names([])
        selections[FilterSectionType.TrackGroup] = .identifiers([])
        selections[FilterSectionType.EventType] = .identifiers([])
        selections[FilterSectionType.Level] = .names([])
        selections[FilterSectionType.Tag] = .names([])
        selections[FilterSectionType.Venue] = .identifiers([])
    }
    
    // MARK: - Methods
    
    /// Updates the filter sections from Realm. 
    /// Removes selections from deleted filters.
    mutating func updateSections() {
        
        filterSections = []
        
        let eventTypes = EventType.from(realm: Store.shared.realm.objects(RealmEventType).sort({ $0.name < $1.name }))
        let summitTrackGroups = TrackGroup.from(realm: Store.shared.realm.objects(RealmTrackGroup).sort({ $0.name < $1.name }))
        let levels = Array(Set(Store.shared.realm.objects(RealmPresentation).map({ $0.level }))).sort().filter { $0 != "" }
        let venues = Venue.from(realm: Store.shared.realm.objects(RealmVenue))
        
        var filterSection: FilterSection
        
        filterSection = FilterSection(type: .ActiveTalks, name: "ACTIVE TALKS")
        let activeTalksFilters = ["Hide Past Talks"]
        
        if let summit = Summit.from(realm: Store.shared.realm.objects(RealmSummit)).first {
            
            let summitTimeZoneOffset = NSTimeZone(name: summit.timeZone)!.secondsFromGMT
            
            let startDate = summit.start.toFoundation().mt_dateSecondsAfter(summitTimeZoneOffset).mt_startOfCurrentDay()
            let endDate = summit.end.toFoundation().mt_dateSecondsAfter(summitTimeZoneOffset).mt_dateDaysAfter(1)
            let now = NSDate()
            
            if now.mt_isBetweenDate(startDate, andDate: endDate) {
                
                filterSection.items = activeTalksFilters.map { FilterSectionItem(identifier: 0, name: $0) }
            }
            else {
                
                filterSection.items = []
            }
        }
        
        filterSections.append(filterSection)
        
        filterSection = FilterSection(type: .TrackGroup, name: "SUMMIT CATEGORY")
        filterSection.items = summitTrackGroups.map { FilterSectionItem(identifier: $0.identifier, name: $0.name) }
        selections[FilterSectionType.TrackGroup]?.update(.identifiers(summitTrackGroups.identifiers))
        
        filterSections.append(filterSection)
        
        filterSection = FilterSection(type: .EventType, name: "EVENT TYPE")
        filterSection.items = eventTypes.map { FilterSectionItem(identifier: $0.identifier, name: $0.name) }
        selections[FilterSectionType.EventType]?.update(.identifiers(eventTypes.identifiers))
        
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
        
        if let summit = Summit.from(realm: Store.shared.realm.objects(RealmSummit)).first {
            
            let summitTimeZoneOffset = NSTimeZone(name: summit.timeZone)!.secondsFromGMT
            
            let startDate = summit.start.toFoundation().mt_dateSecondsAfter(summitTimeZoneOffset).mt_startOfCurrentDay()
            let endDate = summit.end.toFoundation().mt_dateSecondsAfter(summitTimeZoneOffset).mt_dateDaysAfter(1)
            let now = NSDate()
            
            let activeTalksFilters = ["Hide Past Talks"]
            
            if now.mt_isBetweenDate(startDate, andDate: endDate) {
                
                // dont want to override selection
                if didChangeActiveTalks == false {
                    
                    selections[FilterSectionType.ActiveTalks] = .names(activeTalksFilters) // Active Talks filters are static
                }
            }
            else {
                
                // reset active talks selections if the summit has finished (or hasnt started)
                selections[FilterSectionType.ActiveTalks] = .names([])
            }
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

// MARK: - Manager

final class FilterManager {
    
    static let shared = FilterManager()
    
    var filter = Observable(ScheduleFilter())
    
    private var notificationToken: NotificationToken?
    
    private var timer: NSTimer!
    
    deinit {
        
        notificationToken?.stop()
    }
    
    private init() {
        
        // update sections from Realm
        filter.value.updateSections()
        
        notificationToken = Store.shared.realm.addNotificationBlock { [weak self] _,_ in self?.filter.value.updateSections() }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    @objc private func timerUpdate(sender: NSTimer) {
        
        filter.value.updateActiveTalksSelections()
    }
}
