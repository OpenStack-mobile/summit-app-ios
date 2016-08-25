//
//  Filter.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit

public enum FilterSectionType {
    
    case ActiveTalks, SummitType, EventType, Track, TrackGroup, Tag, Level
}

public final class FilterSection {
    public var type : FilterSectionType!
    public var name = ""
    public var items = [FilterSectionItem]()
}

public final class FilterSectionItem {
    public var id = 0
    public var name = ""
}

public final class ScheduleFilter {
    var selections = [FilterSectionType: [AnyObject]]()
    var filterSections = [FilterSection]()
    var hasToRefreshSchedule = true
    
    // MARK: - Private Methods
    
    private func createSectionItem(id: Int, name: String, type: FilterSectionType) -> FilterSectionItem {
        
        let filterSectionItem = FilterSectionItem()
        
        filterSectionItem.id = id
        filterSectionItem.name = name
        
        return filterSectionItem
    }
    
    // MARK: - Methods
    
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