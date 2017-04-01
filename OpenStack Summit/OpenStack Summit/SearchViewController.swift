//
//  SearchViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 3/31/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit
import SwiftFoundation
import CoreSummit

final class SearchViewController: UITableViewController, EventViewController, RevealViewController, UISearchBarDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    
    let fetchLimitPerEntity = 5
    
    var searchTerm: String = "" {
        
        didSet {
            
            let _ = self.view
            
            if searchBar.text != searchTerm {
                
                searchBar.text = searchTerm
            }
            
            searchTermChanged()
        }
    }
    
    private var data: Data = .none {
        
        didSet { configureView() }
    }
    
    var eventRequestInProgress = false
    
    lazy var eventStore: EKEventStore = EKEventStore()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        // setup table view
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.registerNib(R.nib.scheduleTableViewCell)
        // https://github.com/mac-cain13/R.swift/issues/144
        tableView.registerNib(R.nib.searchTableViewHeaderView(), forHeaderFooterViewReuseIdentifier: SearchTableViewHeaderView.reuseIdentifier)
        
        // execute search
        searchTermChanged()
    }
    
    // MARK: - Actions
    
    @IBAction func showEventContextMenu(sender: UIButton) {
        
        let buttonOrigin = sender.convertPoint(.zero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(buttonOrigin)!
        let item = self[indexPath]
        
        guard case let .event(scheduleItem) = item
            else { fatalError("Invalid item \(item) for cell at index path \(indexPath)") }
        
        guard let eventManagedObject = try! EventManagedObject.find(scheduleItem.identifier, context: Store.shared.managedObjectContext)
            else { fatalError("Invalid event \(scheduleItem.identifier)") }
        
        let eventDetail = EventDetail(managedObject: eventManagedObject)
        
        let contextMenu = self.contextMenu(for: eventDetail)
        
        self.show(contextMenu: contextMenu, sender: .view(sender))
    }
    
    @IBAction func showMore(sender: Button) {
        
        switch self.data {
            
        case .none:
            
            break
            
        case .entity:
            
            self.searchTermChanged()
            
        case let .all(sections):
            
            let section = sections[sender.tag]
            
            let entity = section.entity
            
            let items: [Item]
            
            switch entity {
            case .event: items = self.search(ScheduleItem.self, searchTerm: searchTerm, all: true)
            case .speaker: items = self.search(Speaker.self, searchTerm: searchTerm, all: true)
            case .track: items = self.search(Track.self, searchTerm: searchTerm, all: true)
            }
            
            let searchResult = SearchResult(entity: entity, items: items, all: true)
            
            self.data = .entity(searchResult)
        }
    }
    
    // MARK: - Private Methods
    
    private func searchTermChanged() {
        
        if searchTerm.isEmpty {
            
            data = .none
            
        } else {
            
            // fetch all items
            
            var sections = [SearchResult]()
            
            func search<T: SearchViewControllerItem>(type: T.Type, entity: Entity) {
                
                let items = self.search(type, searchTerm: searchTerm, all: false)
                
                guard items.isEmpty == false else { return }
                
                let searchResults = SearchResult(entity: entity, items: items, all: false)
                
                sections.append(searchResults)
            }
            
            // populate sections
            search(ScheduleItem.self, entity: .event)
            search(Speaker.self, entity: .speaker)
            search(Track.self, entity: .track)
            
            data = .all(sections)
        }
    }
    
    private func configureView() {
        
        tableView.reloadData()
    }
    
    private func search<T: SearchViewControllerItem>(type: T.Type, searchTerm: String, all: Bool) -> [Item] {
        
        let context = Store.shared.managedObjectContext
        
        let summit = SummitManager.shared.summit.value
        
        let limit = all ? 0 : fetchLimitPerEntity
        
        let predicate = type.predicate(for: searchTerm, summit: summit)
        
        let results = try! context.managedObjects(type, predicate: predicate, limit: limit)
        
        return results.map { $0.toItem() }
    }
    
    private subscript(indexPath: NSIndexPath) -> Item {
        
        let section: SearchResult
        
        switch data {
        case .none: fatalError("No items")
        case let .all(sections): section = sections[indexPath.section]
        case let .entity(entitySection): section = entitySection
        }
        
        let item = section.items[indexPath.row]
        
        return item
    }
    
    private subscript(section index: Int) -> SearchResult {
        
        let section: SearchResult
        
        switch data {
        case .none: fatalError("No items")
        case let .all(sections): section = sections[index]
        case let .entity(entitySection): section = entitySection
        }
        
        return section
    }
    
    private func configure(cell cell: ScheduleTableViewCell, with event: ScheduleItem) {
        
        // set text
        cell.nameLabel.text = event.name
        cell.dateTimeLabel.text = event.dateTime
        cell.trackLabel.text = event.track
        cell.trackLabel.hidden = event.track.isEmpty
        cell.trackLabel.textColor = UIColor(hexString: event.trackGroupColor) ?? UIColor(hexString: "#9B9B9B")
        
        // set image
        let isScheduled = Store.shared.isEventScheduledByLoggedMember(event: event.identifier)
        let isFavorite = Store.shared.authenticatedMember?.isFavorite(event: event.identifier) ?? false
        
        if isScheduled {
            
            cell.statusImageView.hidden = false
            cell.statusImageView.image = R.image.contextMenuScheduleAdd()!
            
        } else if isFavorite {
            
            cell.statusImageView.hidden = false
            cell.statusImageView.image = R.image.contextMenuWatchListAdd()!
            
        } else {
            
            cell.statusImageView.hidden = true
            cell.statusImageView.image = nil
            
        }
        
        // configure button
        cell.contextMenuButton.addTarget(self, action: #selector(showEventContextMenu), forControlEvents: .TouchUpInside)
    }
    
    private func configure(cell cell: PeopleTableViewCell, with speaker: Speaker) {
        
        cell.name = speaker.name
        cell.title = speaker.title
        cell.pictureURL = speaker.pictureURL
    }
    
    private func configure(cell cell: SearchResultTableViewCell, with track: Track) {
        
        cell.itemLabel.text = track.name
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.searchTerm = searchBar.text ?? ""
        
        searchBar.endEditing(true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        switch data {
        case .none: return 0
        case let .all(sections): return sections.count
        case .entity: return 1
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        
        let section = self[section: sectionIndex]
        
        return section.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = self[indexPath]
        
        switch item {
            
        case let .event(event):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.scheduleTableViewCell, forIndexPath: indexPath)!
            
            configure(cell: cell, with: event)
            
            return cell
            
        case let .speaker(speaker):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell, forIndexPath: indexPath)!
            
            configure(cell: cell, with: speaker)
            
            return cell
            
        case let .track(track):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.searchResultTableViewCell, forIndexPath: indexPath)!
            
            configure(cell: cell, with: track)
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView? {
        
        let section = self[section: sectionIndex]
        
        let sectionTitle: String
        
        switch section.entity {
        case .event: sectionTitle = "EVENTS"
        case .speaker: sectionTitle = "SPEAKERS"
        case .track: sectionTitle = "TRACKS"
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SearchTableViewHeaderView.reuseIdentifier) as! SearchTableViewHeaderView
        
        headerView.titleLabel.text = sectionTitle
        
        let buttonText = section.all ? "Show All Results" : "See All"
        
        headerView.moreButton.setTitle(buttonText, forState: .Normal)
        
        if headerView.moreButton.allTargets().isEmpty {
            
            headerView.moreButton.addTarget(self, action: #selector(showMore), forControlEvents: .TouchUpInside)
        }
        
        headerView.moreButton.tag = sectionIndex
        
        return headerView
    }
}

// MARK: - Supporting Types

final class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var itemLabel: UILabel!
}

private extension SearchViewController {
    
    struct SearchResult {
        let entity: Entity
        let items: [Item]
        let all: Bool
    }
    
    enum Data {
        
        case none
        case all([SearchResult])
        case entity(SearchResult)
    }
    
    enum Entity {
        
        case event
        case speaker
        case track
    }
    
    enum Item {
        
        case event(ScheduleItem)
        case speaker(Speaker)
        case track(Track)
    }
    
    enum SeeMore {
        
        case none
    }
}

private protocol SearchViewControllerItem: CoreDataDecodable {
    
    func toItem() -> SearchViewController.Item
    
    static func predicate(for searchTerm: String, summit: Identifier) -> NSPredicate
}

extension ScheduleItem: SearchViewControllerItem {
    
    private func toItem() -> SearchViewController.Item { return .event(self) }
    
    private static func predicate(for searchTerm: String, summit: Identifier) -> NSPredicate {
        
        return NSPredicate(format: "summit.id == %@ AND (name CONTAINS[c] %@ OR sponsors.name CONTAINS[c] %@)", NSNumber(longLong: Int64(summit)), searchTerm, searchTerm)
    }
}

extension Speaker: SearchViewControllerItem {
    
    private func toItem() -> SearchViewController.Item { return .speaker(self) }
    
    private static func predicate(for searchTerm: String, summit: Identifier) -> NSPredicate {
        
        return NSPredicate(format: "summits.id CONTAINS %@ AND (firstName CONTAINS[c] %@ OR firstName CONTAINS[c] %@ OR affiliations.organization.name CONTAINS[c] %@)", NSNumber(longLong: Int64(summit)), searchTerm, searchTerm, searchTerm)
    }
}

extension Track: SearchViewControllerItem {
    
    private func toItem() -> SearchViewController.Item { return .track(self) }
    
    private static func predicate(for searchTerm: String, summit: Identifier) -> NSPredicate {
        
        return NSPredicate(format: "summits.id CONTAINS %@ AND name CONTAINS[c] %@", NSNumber(longLong: Int64(summit)), searchTerm)
    }
}


