//
//  FilterSelections.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

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
}
