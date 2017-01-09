//
//  SearchMembersViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/9/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import SwiftFoundation
import CoreSummit

final class SearchMembersViewController: UITableViewController, UISearchBarDelegate, MessageEnabledViewController, ShowActivityIndicatorProtocol {
    
    typealias Scope = MemberListRequest.Filter.Property
    
    typealias SortDescriptor = MemberListRequest.SortDescriptor
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    
    var didCancel: ((SearchMembersViewController) -> ())? {
        
        didSet { self.navigationItem.leftBarButtonItem?.enabled = didCancel != nil }
    }
    
    var selectedMember: (SearchMembersViewController, Member) -> () = { _ in }
    
    private(set) var scope: Scope = .firstName
    
    lazy var pageController: PageController<Member> = PageController(fetch: self.fetch)
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 98
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(R.nib.loadingTableViewCell)
        
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        search()
    }
    
    // MARK: - Actions
    
    @IBAction func search(sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    @IBAction func cancel(sender: AnyObject? = nil) {
        
        self.didCancel?(self)
    }
    
    // MARK: - Private Methods
    
    private func fetch(page: Int, perPage: Int, completion: (ErrorValue<Page<Member>>) -> ()) {
        
        let filter: MemberListRequest.Filter?
        
        if let searchText = self.searchBar.text {
            
            filter = MemberListRequest.Filter(value: searchText, property: scope)
            
        } else {
            
            filter = nil
        }
        
        let sort = scope.preferredSortDescriptor
        
        Store.shared.members(filter, sort: sort, page: page, perPage: perPage, completion: completion)
    }
    
    private func willLoadData() {
        
        if pageController.pages.isEmpty {
            
            showActivityIndicator()
        }
    }
    
    private func didLoadNextPage(response: ErrorValue<[PageControllerChange]>) {
        
        hideActivityIndicator()
        
        switch response {
            
        case let .Error(error):
            
            showErrorMessage(error as NSError)
            
        case let .Value(changes):
            
            tableView.beginUpdates()
            
            for change in changes {
                
                let indexPath = NSIndexPath(forRow: change.index, inSection: 0)
                
                switch change.change {
                    
                case .delete:
                    
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                case .insert:
                    
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                case .update:
                    
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
            
            tableView.endUpdates()
        }
    }
    
    private func configure(cell cell: PeopleTableViewCell, with member: Member) {
        
        cell.name = member.name
        cell.pictureURL = member.pictureURL
        
        switch self.scope {
            
        case .twitter:
            
            cell.title = member.twitter
            
        case .irc:
            
            cell.title = member.irc
            
        case .firstName, .lastName:
            
            cell.title = member.title
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pageController.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = self.pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(member):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell, forIndexPath: indexPath)!
            
            configure(cell: cell, with: member)
            
            return cell
            
        case .loading:
            
            pageController.loadNextPage()
            
            return tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.loadingTableViewCell, forIndexPath: indexPath)!
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let data = self.pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(member):
            
            self.selectedMember(self, member)
            
        case .loading: break
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.search()
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        self.scope = Scope(scopeIndex: selectedScope)!
        
        self.search()
    }
}

// MARK: - Supporting Types

private extension SearchMembersViewController.Scope {
    
    init?(scopeIndex: Int) {
        
        switch scopeIndex {
            
        case 0: self = .firstName
        case 1: self = .lastName
        case 2: self = .twitter
        case 3: self = .irc
            
        default: return nil
        }
    }
    
    var preferredSortDescriptor: SearchMembersViewController.SortDescriptor {
        
        switch self {
        case .firstName: return .firstName
        case .lastName: return .lastName
        case .twitter: return .firstName
        case .irc: return .firstName
        }
    }
}
