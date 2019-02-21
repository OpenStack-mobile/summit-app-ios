//
//  GeneralScheduleFilterViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 3/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import UIKit
import Foundation
import CoreSummit
import Predicate

final class GeneralScheduleFilterViewController: UITableViewController {
    
    // MARK: - Properties
    
    public var groupRow: GroupRow? = nil
    
    private var filters = [Section]()
    
    private var filterObserver: Int?
    
    // MARK: - Accesors
    
    private var sections: [Section] {
        
        get {
            
            if let groupRow = self.groupRow {
                
                return self.filters.filter {
                    
                    switch $0.type {
                    case .rows(let rows): return rows.first?.filter.parentCategory == groupRow.filter.category
                    default: return false
                    }
                }
            }
            
            return self.filters
        }
    }
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = filterObserver { FilterManager.shared.filter.remove(observer) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup table view
        tableView.estimatedRowHeight = 48
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        
        // https://github.com/mac-cain13/R.swift/issues/144
        tableView.register(R.nib.tableViewHeaderViewLight(), forHeaderFooterViewReuseIdentifier: TableViewHeaderView.reuseIdentifier)
        
        // observe filter
        filterObserver = FilterManager.shared.filter.observe { [weak self] _, _ in self?.configureView() }
        
        //  setup UI
        configureNavigationBar()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FilterManager.shared.filter.value.update()
        
        // reload table view data after returning sub filtering
        if !isBeingPresented && !isMovingToParentViewController {
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func filterChanged(_ sender: UISwitch) {
        
        let buttonOrigin = sender.convert(CGPoint.zero, to: tableView)
        
        let indexPath = tableView.indexPathForRow(at: buttonOrigin)!
        
        let section = self.sections[indexPath.section]
        
        switch section.type {
            
        case .rows(let rows):
            
            let row = rows[indexPath.row]
            
            if sender.isOn {
                
                FilterManager.shared.filter.value.enable(row.filter)
                
            } else {
                
                FilterManager.shared.filter.value.disable(row.filter)
            }
            
        case .mixed(let rows):
            
            guard let row = rows[indexPath.row] as? Row else { return }
            
            if sender.isOn {
                
                FilterManager.shared.filter.value.enable(row.filter)
                
            } else {
                
                FilterManager.shared.filter.value.disable(row.filter)
            }
            
        default: break
        }
    }
    
    @IBAction func dismiss(_ sender: AnyObject? = nil) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func configureNavigationBar() {
        
        if let groupRow = self.groupRow {
            
            self.navigationItem.leftBarButtonItem = nil
            self.title = groupRow.name.uppercased()
        }
        else { self.setBlankBackBarButtonItem() }
    }
    
    private func configureView() {
        
        let scheduleFilter = FilterManager.shared.filter.value
        
        let context = Store.shared.managedObjectContext
        
        // load table data from current schedule filter
        filters = []
        
        func identifier(for filter: Filter) -> Identifier {
            
            switch filter {
            case let .track(identifier): return identifier
            case let .trackGroup(identifier): return identifier
            case let .venue(identifier): return identifier
            case let .room(identifier): return identifier
            default: fatalError("Invalid filter: \(filter)")
            }
        }
        
        func name(for filter: Filter) -> String {
            
            switch filter {
            case .activeTalks: return "Hide Past Sessions"
            case .video: return "Sessions With Video"
            case let .level(level): return level.rawValue
            default: fatalError("Invalid filter: \(filter)")
            }
        }
        
        if let activeTalksSection = scheduleFilter.allFilters[.activeTalks] {
            
            let rows = activeTalksSection.map { Row(filter: $0, name: name(for: $0), enabled: scheduleFilter.activeFilters.contains($0)) }
            
            filters.append(Section(category: .activeTalks, type: .rows(rows)))
        }
        
        if let trackGroupsSection = scheduleFilter.allFilters[.trackGroup] {
            
            var tracks = [Track]()
            
            if let _ = scheduleFilter.allFilters[.track] {
                
                // fetch from CoreData because it caches fetch request results and is more efficient
                let identifiers = scheduleFilter.activeFilters.filter {
                    switch $0 {
                    case .track: return true
                    default: return false
                    }
                }.map { identifier(for: $0) }
                
                //let predicate = NSPredicate(format: "id IN %@", identifiers)
                let predicate: Predicate = (#keyPath(TrackManagedObject.id)).in(identifiers)
                
                tracks = try! context.managedObjects(Track.self, predicate: predicate, sortDescriptors: Track.ManagedObject.sortDescriptors)
            }
            
            // fetch from CoreData because it caches fetch request results and is more efficient
            let identifiers = trackGroupsSection.map { identifier(for: $0) }
            
            //let predicate = NSPredicate(format: "id IN %@", identifiers)
            let predicate: Predicate = (#keyPath(TrackGroupManagedObject.id)).in(identifiers)
            
            let trackGroups = try! context.managedObjects(TrackGroup.self, predicate: predicate, sortDescriptors: TrackGroup.ManagedObject.sortDescriptors)
            
            let groupRows = trackGroups.map { trackGroup in
                
                GroupRow(filter: .trackGroup(trackGroup.identifier),
                          name: trackGroup.name,
                          color: trackGroup.color,
                          rows: tracks
                            .filter { $0.groups.contains(trackGroup.identifier) }
                            .map { Row(filter: .track($0.identifier), name: $0.name, enabled: true ) } )
            }
            
            filters.append(Section(category: .trackGroup, type: .groups(groupRows)))
        }
        
        if let groupRow = self.groupRow,
            groupRow.filter.category == .trackGroup,
            let trackGroup = groupRow.filter.identifier,
            let tracksSection = scheduleFilter.allFilters[.track] {
            
            // fetch from CoreData because it caches fetch request results and is more efficient
            let identifiers = tracksSection.map { identifier(for: $0) }
            
            //let scheduledTracks = NSPredicate(format: "id IN %@", identifiers)
            let filteredTracks: Predicate = (#keyPath(TrackManagedObject.id)).in(identifiers)
            
            //let trackGroupsPredicate = NSPredicate(format: "ANY groups.id IN %@", [trackGroups])
            let trackGroupsPredicate: Predicate = (#keyPath(TrackManagedObject.groups.id)).any(in: [trackGroup])
                
            let predicate: Predicate = .compound(.and([filteredTracks, trackGroupsPredicate]))
            
            let tracks = try! context.managedObjects(Track.self, predicate: predicate, sortDescriptors: Track.ManagedObject.sortDescriptors)
            
            let rows = tracks.map { Row(filter: .track($0.identifier), name: $0.name, enabled: scheduleFilter.activeFilters.contains(.track($0.identifier))) }
            
            filters.append(Section(category: .track, type: .rows(rows)))
        }
 
        if let levelsSection = scheduleFilter.allFilters[.level] {
            
            let rows = levelsSection.map { Row(filter: $0, name: name(for: $0), enabled: scheduleFilter.activeFilters.contains($0)) }
            
            filters.append(Section(category: .level, type: .rows(rows)))
        }
        
        if let venuesSection = scheduleFilter.allFilters[.venue] {
            
            var rooms = [VenueRoom]()
            
            if let _ = scheduleFilter.allFilters[.room] {
                
                // fetch from CoreData because it caches fetch request results and is more efficient
                let identifiers = scheduleFilter.activeFilters.filter {
                    switch $0 {
                    case .room: return true
                    default: return false
                    }
                    }.map { identifier(for: $0) }
                
                //let predicate = NSPredicate(format: "id IN %@", identifiers)
                let predicate: Predicate = (#keyPath(VenueRoomManagedObject.id)).in(identifiers)
                
                rooms = try! context.managedObjects(VenueRoom.self, predicate: predicate, sortDescriptors: VenueRoom.ManagedObject.sortDescriptors)
            }
            
            // fetch from CoreData because it caches fetch request results and is more efficient
            let identifiers = venuesSection.map { identifier(for: $0) }
            
            //let predicate = NSPredicate(format: "id IN %@", identifiers)
            let predicate: Predicate = (#keyPath(VenueManagedObject.id)).in(identifiers)
            
            var venues = try! context.managedObjects(Venue.self, predicate: predicate, sortDescriptors: Venue.ManagedObject.sortDescriptors)
            
            venues = venues.sorted {
                
                var roomsCount0 = 0;
                
                for floor in $0.floors {
                    
                    roomsCount0 += floor.rooms.count
                }
                
                var roomsCount1 = 0;
                
                for floor in $1.floors {
                    
                    roomsCount1 += floor.rooms.count
                }
                
                return roomsCount0 > roomsCount1
            }
            
            let rows: [FilterRow] = venues.map { venue in
                
                var roomsCount = 0
                
                for floor in venue.floors {
                    
                    roomsCount += floor.rooms.count
                }
                
                if roomsCount == 0 {
                    
                    return Row(filter: .venue(venue.identifier),
                               name: venue.name,
                               enabled: scheduleFilter.activeFilters.contains(.venue(venue.identifier)))
                }
                
                let rooms = rooms
                    .filter { $0.venue == venue.identifier }
                    .map { Row(filter: .room($0.identifier), name: $0.name, enabled: true ) }
                
                return GroupRow(filter: .venue(venue.identifier),
                                name: venue.name,
                                color: nil,
                                rows: rooms)
            }
            
            filters.append(Section(category: .venue, type: .mixed(rows)))
        }
        
        if let groupRow = self.groupRow,
            groupRow.filter.category == .venue,
            let venue = groupRow.filter.identifier,
            let roomsSection = scheduleFilter.allFilters[.room] {
            
            // fetch from CoreData because it caches fetch request results and is more efficient
            let identifiers = roomsSection.map { identifier(for: $0) }
            
            //let scheduledRooms = NSPredicate(format: "id IN %@", identifiers)
            let filteredRooms: Predicate = (#keyPath(VenueRoomManagedObject.id)).in(identifiers)
            
            //let venuePredicate = NSPredicate(format: "ANY venue.id IN %@", [venue])
            let venuePredicate: Predicate = (#keyPath(VenueRoomManagedObject.venue.id)).any(in: [venue])
            
            let predicate: Predicate = .compound(.and([filteredRooms, venuePredicate]))
            
            let rooms = try! context.managedObjects(VenueRoom.self, predicate: predicate, sortDescriptors: VenueRoom.ManagedObject.sortDescriptors)
            
            let rows = rooms.map { Row(filter: .room($0.identifier), name: $0.name, enabled: scheduleFilter.activeFilters.contains(.room($0.identifier))) }
            
            filters.append(Section(category: .room, type: .rows(rows)))
        }
    }
    
    private func configure(cell: GeneralScheduleFilterTableViewCell, with item: Row) {
        
        cell.nameLabel.text = item.name
        cell.enabledSwitch.isOn = item.enabled
    }
    
    private func configure(cell: GeneralScheduleGroupFilterTableViewCell, with groupRow: GroupRow) {
        
        cell.nameLabel.text = groupRow.name
        cell.activeFiltersLabel.text = groupRow.rows.count > 0 ? activeFilters(for: groupRow) : ""
        
        if let circleView = cell.circleView {
            
            circleView.backgroundColor = .clear
            
            if let colorHex = groupRow.color,
                let color = UIColor(hexString: colorHex) {
                
                if groupRow.rows.count > 0 {
                    
                    circleView.backgroundColor = color
                    
                } else {
                    
                    circleView.layer.borderWidth = 1
                    circleView.layer.borderColor = color.cgColor
                }
            }
        }
    }
    
    private func title(for category: FilterCategory) -> String {
        
        let title: String
        
        switch category {
            
        case .activeTalks: title = "ACTIVE TALKS"
        case .trackGroup: title = "CATEGORIES"
        case .track: title = "TRACKS"
        case .level: title = "LEVELS"
        case .venue: title = "VENUES"
        case .room: title = "ROOMS"
            
        }
        
        return title
    }
    
    private func activeFilters(for group: GroupRow) -> String {
        
        return group.rows.map { $0.name.trimmingCharacters(in: .whitespaces) }.joined(separator: ", ")
    }
    
    private func configure(header headerView: TableViewHeaderView, for section: Int) {
        
        let filterCategory = self.sections[section].category
        
        headerView.titleLabel.text = title(for: filterCategory)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = self.sections[section]
        
        switch section.type {
            
        case .rows(let rows): return rows.count
            
        case .groups(let rows): return rows.count
            
        case .mixed(let rows): return rows.count
        
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = self.sections[indexPath.section]
        
        switch section.type {
            
        case .rows(let rows):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.generalScheduleFilterTableViewCell, for: indexPath)!
            
            configure(cell: cell, with: rows[indexPath.row])
            
            return cell
            
        case .groups(let rows):
            
            let identifier = section.category == .trackGroup ? R.reuseIdentifier.generalScheduleTrackGroupFilterTableViewCell : R.reuseIdentifier.generalScheduleGroupFilterTableViewCell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)!
            
            configure(cell: cell, with: rows[indexPath.row])
            
            return cell
        
        case .mixed(let rows):
            
            if let row = rows[indexPath.row] as? Row {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.generalScheduleFilterTableViewCell, for: indexPath)!
                
                configure(cell: cell, with: row)
                
                return cell
                
            } else if let row = rows[indexPath.row] as? GroupRow {
                
                let identifier = section.category == .trackGroup ? R.reuseIdentifier.generalScheduleTrackGroupFilterTableViewCell : R.reuseIdentifier.generalScheduleGroupFilterTableViewCell
                
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)!
                
                configure(cell: cell, with: row)
                
                return cell
            }
            
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewHeaderView.reuseIdentifier) as! TableViewHeaderView
        
        configure(header: headerView, for: section)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = self.sections[indexPath.section]
        
        switch section.type {
            
        case .groups(let rows):
            
            let groupRow = rows[indexPath.row]
            
            let generalScheduleFilterViewController = R.storyboard.scheduleFilter.generalScheduleFilterViewController()!
            
            generalScheduleFilterViewController.groupRow = groupRow
            
            self.navigationController?.pushViewController(generalScheduleFilterViewController, animated: true)
        
        case .mixed(let rows):
            
            guard let groupRow = rows[indexPath.row] as? GroupRow else { return }
            
            let generalScheduleFilterViewController = R.storyboard.scheduleFilter.generalScheduleFilterViewController()!
            
            generalScheduleFilterViewController.groupRow = groupRow
            
            self.navigationController?.pushViewController(generalScheduleFilterViewController, animated: true)
            
        default: break
            
        }
    }
}

protocol FilterRow {
    
    var filter: Filter { get }
    var name: String { get }
}
// MARK: - Supporting Types

extension GeneralScheduleFilterViewController {
    
    enum SectionType {
        
        case rows([Row])
        case groups([GroupRow])
        case mixed([FilterRow])
    }
    
    struct Section {
        
        let category: FilterCategory
        let type: SectionType
    }
    
    struct GroupRow: FilterRow {
        
        let filter: Filter
        let name: String
        let color: String?
        let rows: [Row]
    }
    
    struct Row: FilterRow {
        
        let filter: Filter
        let name: String
        let enabled: Bool
    }
}

final class GeneralScheduleGroupFilterTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var circleView: UIView!
    @IBOutlet private(set) weak var circleContainerView: UIView!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var activeFiltersLabel: UILabel!
}

final class GeneralScheduleFilterTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var enabledSwitch: UISwitch!
}
