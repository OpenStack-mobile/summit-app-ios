//
//  GeneralSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IGeneralScheduleFilterPresenter {
    func showFilters()
}

public class GeneralScheduleFilterPresenter: NSObject, IGeneralScheduleFilterPresenter {
    
    var genereralScheduleFilterInteractor: IGeneralScheduleFilterInteractor!
    var viewController: IGeneralScheduleFilterViewController!
    var session: ISession!
    var filterSelections: Dictionary<FilterSectionTypes, [Int]>?
    
    public init(session: ISession, genereralScheduleFilterInteractor: IGeneralScheduleFilterInteractor) {
        self.session = session
        self.genereralScheduleFilterInteractor = genereralScheduleFilterInteractor
    }
    
    public override init() {
        super.init()
        filterSelections = session.get(Constants.SessionKeys.GeneralScheduleFilterSelections) as? Dictionary<FilterSectionTypes, [Int]>
        if (filterSelections == nil) {
            filterSelections = Dictionary<FilterSectionTypes, [Int]>()
        }
    }
    
    public func showFilters() {
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

        viewController.showFilters(filterSections)
    }
  
    private func createSectionItem(id: Int, name: String, type: FilterSectionTypes) -> FilterSectionItem {
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
    
    public func applyFilter(filterSections: [FilterSection]) {
        var filterSelectionsForType: [Int]
        for filterSection in filterSections {
            filterSelectionsForType = [Int]()
            for filterSectionItem in filterSection.items {
                if (filterSectionItem.selected) {
                    filterSelectionsForType.append(filterSectionItem.id)
                }
            }
            filterSelections![filterSection.type] = filterSelectionsForType
        }
        session.set(Constants.SessionKeys.GeneralScheduleFilterSelections, value: filterSelections as? AnyObject)
    }
}
