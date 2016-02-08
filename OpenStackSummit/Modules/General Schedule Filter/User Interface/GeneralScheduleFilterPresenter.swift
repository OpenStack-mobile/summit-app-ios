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
    func dismissViewController()
    func getSummitTypeItemCount() -> Int
    func getEventTypeItemCount() -> Int
    func getTrackGroupItemCount() -> Int
    func getLevelItemCount() -> Int
    func toggleSelectionSummitType(cell: IGeneralScheduleFilterTableViewCell, index: Int)
    func toggleSelectionEventType(cell: IGeneralScheduleFilterTableViewCell, index: Int)
    func toggleSelectionTrackGroup(cell: IGeneralScheduleFilterTableViewCell, index: Int)
    func toggleSelectionLevel(cell: IGeneralScheduleFilterTableViewCell, index: Int)
    func buildSummitTypeFilterCell(cell: IGeneralScheduleFilterTableViewCell, index: Int)
    func buildTrackGroupFilterCell(cell: IGeneralScheduleFilterTableViewCell, index: Int)
    func buildEventTypeFilterCell(cell: IGeneralScheduleFilterTableViewCell, index: Int)
    func buildLevelFilterCell(cell: IGeneralScheduleFilterTableViewCell, index: Int)
    func getTagsBySearchTerm(searchTerm: String) -> [String]
    func addTag(tag: String) -> Bool
    func removeTag(tag: String)
    func removeAllTags()
}

public class GeneralScheduleFilterPresenter: NSObject, IGeneralScheduleFilterPresenter {
    
    var interactor: IGeneralScheduleFilterInteractor!
    var viewController: IGeneralScheduleFilterViewController!
    var wireframe: IGeneralScheduleFilterWireframe!
    var session: ISession!
    var scheduleFilter: ScheduleFilter!
    var filteredTags = [String]()
    
    public init(session: ISession, genereralScheduleFilterInteractor: IGeneralScheduleFilterInteractor) {
        self.session = session
        self.interactor = genereralScheduleFilterInteractor
    }
    
    public override init() {
        super.init()
    }
    
    public func dismissViewController() {
        wireframe.dismissFilterView()
    }
    
    public func viewLoad() {
        if (scheduleFilter.filterSections.count == 0) {
            let summitTypes = interactor.getSummitTypes()
            let eventTypes = interactor.getEventTypes()
            let summitTracks = interactor.getTracks()
            let summitTrackGroups = interactor.getTrackGroups()
            let levels = interactor.getLevels()
            
            scheduleFilter.selections[FilterSectionType.SummitType] = [Int]()
            var filterSection = FilterSection()
            filterSection.type = FilterSectionType.SummitType
            filterSection.name = "Credentials"
            var filterSectionItem: FilterSectionItem
            for summitType in summitTypes {
                filterSectionItem = createSectionItem(summitType.id, name: summitType.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)

            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.TrackGroup] = [Int]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.TrackGroup
            filterSection.name = "Track Group"
            for trackGroup in summitTrackGroups {
                filterSectionItem = createSectionItem(trackGroup.id, name: trackGroup.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.EventType] = [Int]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.EventType
            filterSection.name = "Event Type"
            for eventType in eventTypes {
                filterSectionItem = createSectionItem(eventType.id, name: eventType.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.Level] = [String]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.Level
            filterSection.name = "Levels"
            for level in levels {
                filterSectionItem = createSectionItem(0, name: level, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.Track] = [Int]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.Track
            filterSection.name = "Track"
            for track in summitTracks {
                filterSectionItem = createSectionItem(track.id, name: track.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
            }
            scheduleFilter.filterSections.append(filterSection)

            scheduleFilter.selections[FilterSectionType.Tag] = [Int]()
        }

        viewController.reloadFilters()
        
        viewController.removeAllTags()
        for tag in scheduleFilter.selections[FilterSectionType.Tag]! {
            viewController.addTag(tag as! String)
        }
        
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
                if (id == selectedId as! Int) {
                    return true
                }
            }
        }
        return false
    }

    private func isItemSelected(filterSectionType: FilterSectionType, name: String) -> Bool {
        if let filterSelectionsForType = scheduleFilter.selections[filterSectionType] {
            for selectedName in filterSelectionsForType {
                if (name == selectedName as! String) {
                    return true
                }
            }
        }
        return false
    }
    
    public func getSummitTypeItemCount() -> Int {
        return scheduleFilter.filterSections[0].items.count
    }
    
    public func getTrackGroupItemCount() -> Int {
        return scheduleFilter.filterSections[1].items.count
    }
    
    public func getEventTypeItemCount() -> Int {
        return scheduleFilter.filterSections[2].items.count
    }

    public func getLevelItemCount() -> Int {
        return scheduleFilter.filterSections[3].items.count
    }
    
    public func buildFilterCell(cell: IGeneralScheduleFilterTableViewCell, filterSection: FilterSection, index: Int) {
        let filterItem = filterSection.items[index]
        
        cell.name = filterItem.name
        cell.isOptionSelected = isItemSelected(filterSection.type, id: filterItem.id)
        
        if index == 0 {
            cell.addTopExtraPadding()
        }
        else if index == filterSection.items.count - 1 {
            cell.addBottomExtraPadding()
        }
    }

    public func buildSummitTypeFilterCell(cell: IGeneralScheduleFilterTableViewCell, index: Int) {
        let filterSection = scheduleFilter.filterSections[0]
        buildFilterCell(cell, filterSection: filterSection, index: index)
    }
    
    public func buildTrackGroupFilterCell(cell: IGeneralScheduleFilterTableViewCell, index: Int) {
        let filterSection = scheduleFilter.filterSections[1]
        let trackGroup = interactor.getTrackGroup(filterSection.items[index].id)
        cell.circleColor = UIColor(hexaString: trackGroup!.color)
        buildFilterCell(cell, filterSection: filterSection, index: index)
    }

    public func buildEventTypeFilterCell(cell: IGeneralScheduleFilterTableViewCell, index: Int) {
        let filterSection = scheduleFilter.filterSections[2]
        buildFilterCell(cell, filterSection: filterSection, index: index)
    }

    public func buildLevelFilterCell(cell: IGeneralScheduleFilterTableViewCell, index: Int) {
        let filterSection = scheduleFilter.filterSections[3]
        let filterItem = filterSection.items[index]
        
        cell.name = filterItem.name
        cell.isOptionSelected = isItemSelected(filterSection.type, name: filterItem.name)
        
        if index == 0 {
            cell.addTopExtraPadding()
        }
        else if index == filterSection.items.count - 1 {
            cell.addBottomExtraPadding()
        }
    }
    
    public func toggleSelectionSummitType(cell: IGeneralScheduleFilterTableViewCell, index: Int) {
        let filterSection = scheduleFilter.filterSections[0]
        toggleSelection(cell, filterSection: filterSection, index: index)
    }
    
    public func toggleSelectionTrackGroup (cell: IGeneralScheduleFilterTableViewCell, index: Int) {
        let filterSection = scheduleFilter.filterSections[1]
        toggleSelection(cell, filterSection: filterSection, index: index)
    }
    
    public func toggleSelectionEventType(cell: IGeneralScheduleFilterTableViewCell, index: Int) {
        let filterSection = scheduleFilter.filterSections[2]
        toggleSelection(cell, filterSection: filterSection, index: index)
    }

    public func toggleSelectionLevel(cell: IGeneralScheduleFilterTableViewCell, index: Int) {
        let filterSection = scheduleFilter.filterSections[3]
        let filterItem = filterSection.items[index]
        
        if (isItemSelected(filterSection.type, name: filterItem.name)) {
            let index = scheduleFilter.selections[filterSection.type]!.indexOf { $0 as! String == filterItem.name }
            scheduleFilter.selections[filterSection.type]!.removeAtIndex(index!)
            cell.isOptionSelected = false
        }
        else {
            scheduleFilter.selections[filterSection.type]!.append(filterItem.name)
            cell.isOptionSelected = true
        }
    }
    
    func toggleSelection(cell: IGeneralScheduleFilterTableViewCell, filterSection: FilterSection, index: Int) {
        let filterItem = filterSection.items[index]
        
        if (isItemSelected(filterSection.type, id: filterItem.id)) {
            let index = scheduleFilter.selections[filterSection.type]!.indexOf { $0 as! Int == filterItem.id }
            scheduleFilter.selections[filterSection.type]!.removeAtIndex(index!)
            cell.isOptionSelected = false
        }
        else {
            scheduleFilter.selections[filterSection.type]!.append(filterItem.id)
            cell.isOptionSelected = true
        }
    }
    
    public func getTagsBySearchTerm(searchTerm: String) -> [String] {
        if searchTerm.isEmpty {
            return []
        }
        
        dispatch_sync(dispatch_get_main_queue(),{
            self.filteredTags = self.interactor.getTagsBySearchTerm(searchTerm)
        })
        return self.filteredTags
    }
    
    public func addTag(tag: String) -> Bool {
        let escapedTag = tag.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (escapedTag == "" || scheduleFilter.selections[FilterSectionType.Tag]?.indexOf{ $0 as! String == escapedTag } != nil) {
            return false
        }

        scheduleFilter.selections[FilterSectionType.Tag]!.append(escapedTag)
        return true
    }
    
    public func removeAllTags() {
        scheduleFilter.selections[FilterSectionType.Tag]!.removeAll()
    }

    public func removeTag(tag: String) {
        let escapedTag = tag.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (escapedTag == "") {
            return
        }
        
        let index = scheduleFilter.selections[FilterSectionType.Tag]!.indexOf { $0 as! String == escapedTag }
        scheduleFilter.selections[FilterSectionType.Tag]!.removeAtIndex(index!)
    }
}
