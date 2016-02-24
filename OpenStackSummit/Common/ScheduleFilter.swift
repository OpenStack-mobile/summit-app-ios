//
//  FilterSelections.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

/*protocol IScheduleFilter {
    var selections: Dictionary<FilterSectionType, [AnyObject]> { get set }
    var filterSections: [FilterSection] { get set }
    func hasActiveFilters() -> Bool
    func clearActiveFilters()
}*/

public class ScheduleFilter: NSObject {
    var selections = Dictionary<FilterSectionType, [AnyObject]>()
    var filterSections = [FilterSection]()

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
