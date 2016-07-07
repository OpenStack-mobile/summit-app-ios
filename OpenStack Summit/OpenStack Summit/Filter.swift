//
//  Filter.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public enum FilterSectionType {
    
    case SummitType, EventType, Track, TrackGroup, Tag, Level
}

public class FilterSection {
    public var type : FilterSectionType!
    public var name = ""
    public var items = [FilterSectionItem]()
}

public class FilterSectionItem {
    public var id = 0
    public var name = ""
}

public class ScheduleFilter {
    var selections = [FilterSectionType: [AnyObject]]()
    var filterSections = [FilterSection]()
    var hasToRefreshSchedule = true
    
    func areAllSelectedForType(type: FilterSectionType) -> Bool {
        if (filterSections.count == 0) {
            return false
        }
        let filterSection = filterSections.filter() { $0.type == type }.first!
        return filterSection.items.count == selections[type]?.count
    }
    
    func hasActiveFilters() -> Bool {
        var hasActiveFilters = false
        for values in selections.values {
            if values.count > 0 {
                hasActiveFilters = true
                break
            }
        }
        return hasActiveFilters
    }
    
    func clearActiveFilters() {
        for key in selections.keys {
            selections[key] = []
        }
    }
}