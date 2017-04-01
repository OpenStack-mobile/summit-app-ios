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
import SwiftFoundation
import CoreSummit

final class SearchViewController: UITableViewController, RevealViewController, UISearchBarDelegate {
    
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
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup table view
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.registerNib(R.nib.scheduleTableViewCell)
        tableView.registerNib(R.nib.peopleTableViewCell)
        
        // configure view
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func showMore(sender: Button) {
        
        
    }
    
    // MARK: - Private Methods
    
    private func searchTermChanged() {
        
        if searchTerm.isEmpty {
            
            data = .none
            
        } else {
            
            //
        }
    }
    
    private func configureView() {
        
        
    }
    
    private func search<T: SearchViewControllerItem>(type: T.Type, searchTerm: String, all: Bool = false) -> [Item] {
        
        let context = Store.shared.managedObjectContext
        
        let summit = SummitManager.shared.summit.value
        
        let limit = all ? 0 : fetchLimitPerEntity
        
        let predicate = type.predicate(for: searchTerm, summit: summit)
        
        let results = try! context.managedObjects(type, predicate: predicate, limit: limit)
        
        return results.map { $0.toItem() }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        
    }
}

// MARK: - Supporting Types

private extension SearchViewController {
    
    struct SearchResult {
        let entity: Entity
        let items: [Item]
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
}

private protocol SearchViewControllerItem: CoreDataDecodable {
    
    func toItem() -> SearchViewController.Item
    
    static func predicate(for searchTerm: String, summit: Identifier) -> NSPredicate
}

extension ScheduleItem: SearchViewControllerItem {
    
    private func toItem() -> SearchViewController.Item { return .event(self) }
    
    private static func predicate(for searchTerm: String, summit: Identifier) -> NSPredicate {
        
        let summitPredicate = NSPredicate(format: "summit.id == %@", NSNumber(longLong: Int64(summit)))
        
        let eventNamePredicate = NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
        
        let eventCompanyPredicate = NSPredicate(format: "sponsors.name CONTAINS[c] %@", searchTerm)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            summitPredicate,
            eventNamePredicate,
            eventCompanyPredicate
            ])
    }
}

extension Speaker: SearchViewControllerItem {
    
    private func toItem() -> SearchViewController.Item { return .speaker(self) }
    
    private static func predicate(for searchTerm: String, summit: Identifier) -> NSPredicate {
        
        let summitPredicate = NSPredicate(format: "summits.id CONTAINS %@", NSNumber(longLong: Int64(summit)))
        
        let affiliationOrganizationsPredicate = NSPredicate(format: "affiliations.organization.name CONTAINS[c] %@", searchTerm)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            summitPredicate,
            affiliationOrganizationsPredicate
            ])
    }
}

extension Track: SearchViewControllerItem {
    
    private func toItem() -> SearchViewController.Item { return .track(self) }
    
    private static func predicate(for searchTerm: String, summit: Identifier) -> NSPredicate {
        
        let summitPredicate = NSPredicate(format: "summits.id CONTAINS %@", NSNumber(longLong: Int64(summit)))
        
        let namePredicate = NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            summitPredicate,
            namePredicate
            ])
    }
}


