//
//  GeneralSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IGeneralScheduleFilterPresenter {
    func viewLoad()
    func getSectionCount() -> Int
    func getSectionItemCount(section: Int) -> Int
    func buildFilterCell(cell: IGeneralScheduleFilterTableViewCell, section: Int, index: Int)
    func getSectionTitle(section: Int) -> String
    func toggleSelection(cell: IGeneralScheduleFilterTableViewCell, section: Int, index: Int)
}

public class GeneralScheduleFilterPresenter: NSObject, IGeneralScheduleFilterPresenter {
    
    var interactor: IGeneralScheduleFilterInteractor!
    var viewController: IGeneralScheduleFilterViewController!
    var session: ISession!
    var scheduleFilter: ScheduleFilter!
    
    public init(session: ISession, genereralScheduleFilterInteractor: IGeneralScheduleFilterInteractor) {
        self.session = session
        self.interactor = genereralScheduleFilterInteractor
    }
    
    public override init() {
        super.init()
    }
    
    public func viewLoad() {
        if (scheduleFilter.filterSections.count == 0) {
            let summitTypes = interactor.getSummitTypes()
            let eventTypes = interactor.getEventTypes()
            let summitTracks = interactor.getSummitTracks()
            
            scheduleFilter.selections[FilterSectionType.SummitType] = [Int]()
            var filterSection = FilterSection()
            filterSection.type = FilterSectionType.SummitType
            filterSection.name = "Credentials"
            var filterSectionItem: FilterSectionItem
            for summitType in summitTypes {
                filterSectionItem = createSectionItem(summitType.id, name: summitType.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
                scheduleFilter.selections[filterSection.type]!.append(filterSectionItem.id)

            }
            scheduleFilter.filterSections.append(filterSection)

            scheduleFilter.selections[FilterSectionType.EventType] = [Int]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.EventType
            filterSection.name = "Event Type"
            for eventType in eventTypes {
                filterSectionItem = createSectionItem(eventType.id, name: eventType.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
                scheduleFilter.selections[filterSection.type]!.append(filterSectionItem.id)
            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.Track] = [Int]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.Track
            filterSection.name = "Track"
            for track in summitTracks {
                filterSectionItem = createSectionItem(track.id, name: track.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
                scheduleFilter.selections[filterSection.type]!.append(filterSectionItem.id)
            }
            scheduleFilter.filterSections.append(filterSection)
        }

        viewController.reloadFilters()
    }
  
    private func createSectionItem(id: Int, name: String, type: FilterSectionType) -> FilterSectionItem {
        let filterSectionItem = FilterSectionItem()
        filterSectionItem.id = id
        filterSectionItem.name = name
        return filterSectionItem
    }
    
    private func isItemSelected(filterSectionType: FilterSectionType, id: Int) -> Bool {
        if let filterSelectionsForType = scheduleFilter.selections[filterSectionType] {
            for selectedId in filterSelectionsForType {
                if (id == selectedId) {
                    return true
                }
            }
        }
        return false
    }
    
    public func getSectionItemCount(section: Int) -> Int {
        return scheduleFilter.filterSections[section].items.count
    }
    
    public func getSectionCount() -> Int {
        return scheduleFilter.filterSections.count
    }
    
    public func buildFilterCell(cell: IGeneralScheduleFilterTableViewCell, section: Int, index: Int) {
        let filterSection = scheduleFilter.filterSections[section]
        let filterItem = filterSection.items[index]
        
        cell.name = filterItem.name
        cell.isOptionSelected = isItemSelected(filterSection.type, id: filterItem.id)
    }
    
    public func getSectionTitle(section: Int) -> String {
        return scheduleFilter.filterSections[section].name
    }
    
    public func toggleSelection(cell: IGeneralScheduleFilterTableViewCell, section: Int, index: Int) {
        let filterSection = scheduleFilter.filterSections[section]
        let filterItem = filterSection.items[index]

        if (isItemSelected(filterSection.type, id: filterItem.id)) {
            let index = scheduleFilter.selections[filterSection.type]!.indexOf(filterItem.id)
            scheduleFilter.selections[filterSection.type]!.removeAtIndex(index!)
            cell.isOptionSelected = false
        }
        else {
            scheduleFilter.selections[filterSection.type]!.append(filterItem.id)
            cell.isOptionSelected = true
        }        
    }
}
