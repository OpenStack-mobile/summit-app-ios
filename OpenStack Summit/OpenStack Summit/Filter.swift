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

public struct FilterSectionItem {
    
    public var id: Int
    public var name: String
}

public struct FilterSection {
    
    public var type: FilterSectionType
    public var name: String
    public var items: [FilterSectionItem]
}

public struct ScheduleFilter {
    
    var selections = [FilterSectionType: [FilterSectionItem]]()
    
    var filterSections = [FilterSection]()
    
    var hasToRefreshSchedule = true
    
    func areAllSelected(for type: FilterSectionType) -> Bool {
        
        if (filterSections.count == 0) {
            return false
        }
        let filterSection = filterSections.filter() { $0.type == type }.first!
        return filterSection.items.count == selections[type]?.count
    }
    
    func hasActiveFilters() -> Bool {
        
        for values in selections.values {
            
            if values.count > 0 {
                
                return true
            }
        }
        
        return false
    }
    
    mutating func clearActiveFilters() {
        
        for key in selections.keys {
            
            selections[key] = []
        }
    }
}