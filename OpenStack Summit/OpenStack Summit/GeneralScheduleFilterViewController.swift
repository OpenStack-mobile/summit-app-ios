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
    
    private var filters = [Section]()
    
    private var filterObserver: Int?
    
    private var trackGroup: Identifier? = nil
    
    // MARK: - Accesors
    
    private var sections: [Section] {
        
        get {
            
            return self.filters.filter {
                
                switch $0.category {
                    
                case .track: return self.trackGroup != nil
                default: return self.trackGroup == nil
                    
                }
            }
        }
    }
    
    var trackGroupItem: GroupItem? = nil {
        
        willSet {
            
            guard let groupItem = newValue else { return }
            
            switch groupItem.filter {
                
            case let .trackGroup(identifier): self.trackGroup = identifier
            default: return
                
            }
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.navigationController?.viewControllers.index(of: self) == nil {
            
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func filterChanged(_ sender: UISwitch) {
        
        let buttonOrigin = sender.convert(CGPoint.zero, to: tableView)
        
        let indexPath = tableView.indexPathForRow(at: buttonOrigin)!
        
        let section = self.sections[indexPath.section]
        
        switch section.type {
            
        case let .filter(items):
            
            let item = items[indexPath.row]
            
            if sender.isOn {
                
                FilterManager.shared.filter.value.enable(item.filter)
                
            } else {
                
                FilterManager.shared.filter.value.disable(item.filter)
            }
            
        default: break
        }
    }
    
    @IBAction func dismiss(_ sender: AnyObject? = nil) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func configureNavigationBar() {
        
        if let groupItem = self.trackGroupItem {
            
            self.navigationItem.leftBarButtonItem = nil
            self.title = groupItem.name.uppercased()
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
            default: fatalError("Invalid filter: \(filter)")
            }
        }
        
        func name(for filter: Filter) -> String {
            
            switch filter {
            case .activeTalks: return "Hide Past Talks"
            case let .level(level): return level.rawValue
            default: fatalError("Invalid filter: \(filter)")
            }
        }
        
        if let activeTalksSection = scheduleFilter.allFilters[.activeTalks] {
            
            let items = activeTalksSection.map { Item(filter: $0, name: name(for: $0), enabled: scheduleFilter.activeFilters.contains($0)) }
            
            filters.append(Section(category: .activeTalks, type: .filter(items)))
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
            
            let groupItems = trackGroups.map { trackGroup in
                
                GroupItem(filter: .trackGroup(trackGroup.identifier),
                          name: trackGroup.name,
                          color: trackGroup.color,
                          items: tracks
                            .filter { $0.groups.contains(trackGroup.identifier) }
                            .map { Item(filter: .track($0.identifier), name: $0.name, enabled: true ) } )
            }
            
            filters.append(Section(category: .trackGroup, type: .group(groupItems)))
        }
        
        if let trackGroup = self.trackGroup,
            let tracksSection = scheduleFilter.allFilters[.track] {
            
            // fetch from CoreData because it caches fetch request results and is more efficient
            let identifiers = tracksSection.map { identifier(for: $0) }
            
            //let scheduledTracks = NSPredicate(format: "id IN %@", identifiers)
            let filteredTracks: Predicate = (#keyPath(TrackManagedObject.id)).in(identifiers)
            
            //let trackGroupsPredicate = NSPredicate(format: "ANY groups.id IN %@", [trackGroups])
            let trackGroupsPredicate: Predicate = (#keyPath(TrackManagedObject.groups.id)).any(in: [trackGroup])
                
            let predicate: Predicate = .compound(.and([filteredTracks, trackGroupsPredicate]))
            
            let tracks = try! context.managedObjects(Track.self, predicate: predicate, sortDescriptors: Track.ManagedObject.sortDescriptors)
            
            let items = tracks.map { Item(filter: .track($0.identifier), name: $0.name, enabled: scheduleFilter.activeFilters.contains(.track($0.identifier))) }
            
            filters.append(Section(category: .track, type: .filter(items)))
        }
 
        if let levelsSection = scheduleFilter.allFilters[.level] {
            
            let items = levelsSection.map { Item(filter: $0, name: name(for: $0), enabled: scheduleFilter.activeFilters.contains($0)) }
            
            filters.append(Section(category: .level, type: .filter(items)))
        }
        
        if let venuesSection = scheduleFilter.allFilters[.venue] {
            
            // fetch from CoreData because it caches fetch request results and is more efficient
            let identifiers = venuesSection.map { identifier(for: $0) }
            
            //let predicate = NSPredicate(format: "id IN %@", identifiers)
            let predicate: Predicate = (#keyPath(VenueManagedObject.id)).in(identifiers)
            
            let venues = try! context.managedObjects(Venue.self, predicate: predicate, sortDescriptors: Venue.ManagedObject.sortDescriptors)
            
            let items = venues.map { Item(filter: .venue($0.identifier), name: $0.name, enabled: scheduleFilter.activeFilters.contains(.venue($0.identifier))) }
            
            filters.append(Section(category: .venue, type: .filter(items)))
        }
    }
    
    private func configure(cell: GeneralScheduleFilterTableViewCell, with item: Item) {
        
        cell.nameLabel.text = item.name
        cell.enabledSwitch.isOn = item.enabled
    }
    
    private func configure(cell: GeneralScheduleGroupFilterTableViewCell, with groupItem: GroupItem) {
        
        cell.nameLabel.text = groupItem.name
        
        let color = UIColor(hexString: groupItem.color)
        
        if groupItem.items.count > 0 {
            
            cell.circleView.backgroundColor = color
            cell.activeFiltersLabel.text = activeFilters(for: groupItem)
            
        } else {
            
            cell.circleView.layer.borderWidth = 1
            cell.circleView.layer.borderColor = color?.cgColor
            cell.circleView.backgroundColor = .clear
            cell.activeFiltersLabel.text = ""
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
            
        }
        
        return title
    }
    
    private func activeFilters(for group: GroupItem) -> String {
        
        return group.items.map { $0.name.trimmingCharacters(in: .whitespaces) }.joined(separator: ", ")
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
            
        case let .filter(items): return items.count
            
        case let .group(items): return items.count
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = self.sections[indexPath.section]
        
        switch section.type {
            
        case let .filter(items):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.generalScheduleFilterTableViewCell, for: indexPath)!
            
            configure(cell: cell, with: items[indexPath.row])
            
            return cell
            
        case let .group(groupItems):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.generalScheduleGroupFilterTableViewCell, for: indexPath)!
            
            configure(cell: cell, with: groupItems[indexPath.row])
            
            return cell
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
            
        case let .group(groupItems):
            
            let groupItem = groupItems[indexPath.row]
            
            let generalScheduleFilterViewController = R.storyboard.scheduleFilter.generalScheduleFilterViewController()!
            
            generalScheduleFilterViewController.trackGroupItem = groupItem
            
            self.navigationController?.pushViewController(generalScheduleFilterViewController, animated: true)
            
        default: break
            
        }
    }
}

// MARK: - Supporting Types

extension GeneralScheduleFilterViewController {
    
    enum SectionType {
        
        case group([GroupItem])
        case filter([Item])
    }
    
    struct Section {
        
        let category: FilterCategory
        let type: SectionType
    }
    
    struct GroupItem {
        
        let filter: Filter
        let name: String
        let color: String
        let items: [Item]
    }
    
    struct Item {
        
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
