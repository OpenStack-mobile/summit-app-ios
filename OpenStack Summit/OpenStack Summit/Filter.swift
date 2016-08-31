//
//  Filter.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit

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

struct FilterSectionItem {
    
    let identifier: Identifier
    let name: String
}

enum FilterSelection {
    
    case identifiers([Identifier])
    case names([String])
    
    var rawValue: [AnyObject] {
        
        switch self {
        case let .identifiers(rawValue): return rawValue as [NSNumber]
        case let .names(rawValue): return rawValue as [NSString]
        }
    }
    
    mutating func removeAll() {
        
        switch self {
        case .identifiers: self = .identifiers([])
        case .names: self = .names([])
        }
    }
}

struct ScheduleFilter {
    
    // MARK: - Properties
    
    var selections = [FilterSectionType: FilterSelection]()
    var filterSections = [FilterSection]()
    
    // MARK: - Methods
    
    func areAllSelectedForType(type: FilterSectionType) -> Bool {
        if (filterSections.count == 0) {
            return false
        }
        let filterSection = filterSections.filter() { $0.type == type }.first!
        return filterSection.items.count == selections[type]?.rawValue.count
    }
    
    func hasActiveFilters() -> Bool {
        var hasActiveFilters = false
        for values in selections.values {
            if values.rawValue.count > 0 {
                hasActiveFilters = true
                break
            }
        }
        return hasActiveFilters
    }
    
    mutating func clearActiveFilters() {
        for key in selections.keys {
            selections[key] = []
        }
    }
    
    func shoudHidePastTalks() -> Bool {
        var hidePastTalks = false
        
        if let activeTalks = selections[FilterSectionType.ActiveTalks] as? [String] {
            if activeTalks.contains("Hide Past Talks") {
                hidePastTalks = true
            }
        }
        
        return hidePastTalks
    }
}

extension ScheduleFilter {
    
    static var `default`: ScheduleFilter {
        
        var scheduleFilter = ScheduleFilter()
        
        let eventTypes = EventType.from(realm: Store.shared.realm.objects(RealmEventType).sort({ $0.name < $1.name }))
        let summitTrackGroups = TrackGroup.from(realm: Store.shared.realm.objects(RealmTrackGroup).sort({ $0.name < $1.name }))
        let levels = Array(Set(Store.shared.realm.objects(RealmPresentation).map({ $0.level }))).sort()
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
                scheduleFilter.selections[FilterSectionType.ActiveTalks] = activeTalksFilters
            }
        }
        
        scheduleFilter.filterSections.append(filterSection)
        
        filterSection = FilterSection(type: .TrackGroup, name: "SUMMIT CATEGORY")
        filterSection.items = summitTrackGroups.map { FilterSectionItem(identifier: $0.identifier, name: $0.name) }
        
        scheduleFilter.filterSections.append(filterSection)
        scheduleFilter.selections[FilterSectionType.TrackGroup] = [Int]()
        
        filterSection = FilterSection(type: .EventType, name: "EVENT TYPE")
        filterSection.items = eventTypes.map { FilterSectionItem(identifier: $0.identifier, name: $0.name) }
        
        scheduleFilter.filterSections.append(filterSection)
        scheduleFilter.selections[FilterSectionType.EventType] = [Int]()
        
        filterSection = FilterSection(type: .Level, name: "LEVEL")
        filterSection.items = levels.map { FilterSectionItem(identifier: 0, name: $0) }
        
        scheduleFilter.filterSections.append(filterSection)
        scheduleFilter.selections[FilterSectionType.Level] = [String]()
        
        scheduleFilter.selections[FilterSectionType.Tag] = [Int]()
        
        filterSection = FilterSection(type: .Venue, name: "VENUE")
        filterSection.items = venues.map { FilterSectionItem(identifier: $0.identifier, name: $0.name) }
        scheduleFilter.filterSections.append(filterSection)
        scheduleFilter.selections[FilterSectionType.Venue] = [Int]()
        
        return scheduleFilter
    }
}
