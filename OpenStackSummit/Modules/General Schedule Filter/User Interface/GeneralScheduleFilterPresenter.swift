//
//  GeneralSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IGeneralScheduleFilterPresenter {
    func getFilterItems() -> [FilterSection]    
}

public class GeneralScheduleFilterPresenter: NSObject {
    
    var genereralScheduleFilterInteractor: IGeneralScheduleFilterInteractor!
    var session: ISession!
    var filterSelections: Dictionary<FilterSectionTypes, [Int]>?
    
    public override init() {
        super.init()
        filterSelections = session.get("generalScheduleFilterSelections") as? Dictionary<FilterSectionTypes, [Int]>
    }
    
    public func getFilterItems() -> [FilterSection] {
        let summitTypes = genereralScheduleFilterInteractor.getSummitTypes()
        let eventTypes = genereralScheduleFilterInteractor.getEventTypes()
        let summitTracks = genereralScheduleFilterInteractor.getSummitTracks()
        
        var filterSections = [FilterSection]()
        
        var filterSection = FilterSection()
        filterSection.type = FilterSectionTypes.SummitType
        filterSection.name = "Credentials"
        var filterSectionItem: FilterSectionItem
        for summitType in summitTypes {
            filterSectionItem = createSectionItem(summitType.id, name: summitType.name, type: filterSection.type)
            filterSection.items.append(filterSectionItem)
        }
        filterSections.append(filterSection)

        filterSection = FilterSection()
        filterSection.type = FilterSectionTypes.EventType
        filterSection.name = "Event Type"
        for eventType in eventTypes {
            filterSectionItem = createSectionItem(eventType.id, name: eventType.name, type: filterSection.type)
            filterSection.items.append(filterSectionItem)
        }
        filterSections.append(filterSection)
        
        filterSection = FilterSection()
        filterSection.type = FilterSectionTypes.Track
        filterSection.name = "Track"
        for track in summitTracks {
            filterSectionItem = createSectionItem(track.id, name: track.name, type: filterSection.type)
            filterSection.items.append(filterSectionItem)
        }
        filterSections.append(filterSection)
        
        return filterSections
    }
  
    func createSectionItem(id: Int, name: String, type: FilterSectionTypes) -> FilterSectionItem {
        let filterSectionItem = FilterSectionItem()
        filterSectionItem.id = id
        filterSectionItem.name = name
        filterSectionItem.selected = isItemSelected(type, id: id)
        return filterSectionItem
    }
    
    private func isItemSelected(filterSectionType: FilterSectionTypes, id: Int) -> Bool {
        if let filterSelectionsForType = filterSelections?[filterSectionType] {
            for selectedId in filterSelectionsForType {
                if (id == selectedId) {
                    return true
                }
            }
        }
        return false
    }
}
