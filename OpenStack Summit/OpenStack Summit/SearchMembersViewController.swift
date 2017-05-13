//
//  SearchMembersViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/9/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import CoreSummit
import JGProgressHUD

final class SearchMembersViewController: UITableViewController, UISearchBarDelegate, PagingTableViewController {
    
    typealias Scope = MemberListRequest.Filter.Property
    
    typealias SortDescriptor = MemberListRequest.SortDescriptor
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
    @IBOutlet private var cancelButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    var didCancel: ((SearchMembersViewController) -> ())? {
        
        didSet { configureView() }
    }
    
    var selectedMember: (SearchMembersViewController, Member) -> () = { _ in }
    
    private(set) var scope: Scope = .firstName
    
    lazy var pageController: PageController<Member> = PageController(fetch: self.fetch)
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 98
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.loadingTableViewCell)
        
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        search()
        
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func search(_ sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    @IBAction func cancel(_ sender: AnyObject? = nil) {
        
        self.didCancel?(self)
    }
    
    // MARK: - Private Methods
    
    private func fetch(page: Int, perPage: Int, completion: @escaping (ErrorValue<Page<Member>>) -> ()) {
        
        // dont make request for empty search filter
        guard let searchText = self.searchBar.text,
            searchText.isEmpty == false
            else { completion(.value(.empty)); return }
        
        let filter = MemberListRequest.Filter(value: searchText, property: scope)
        
        let sort = scope.preferredSortDescriptor
        
        Store.shared.members(filter, sort: sort, page: page, perPage: perPage, completion: completion)
    }
    
    func willLoadData() {
        
        if pageController.pages.isEmpty && (self.searchBar.text?.isEmpty ?? true) == false {
            
            showActivityIndicator()
        }
    }
    
    private func configure(cell: PeopleTableViewCell, with member: Member) {
        
        cell.name = member.name
        cell.picture = member.picture
        
        switch self.scope {
            
        case .twitter:
            
            cell.title = member.twitter ?? ""
            
        case .irc:
            
            cell.title = member.irc ?? ""
            
        case .firstName, .lastName:
            
            cell.title = member.title ?? ""
        }
    }
    
    private func configureView() {
        
        self.navigationItem.leftBarButtonItem = didCancel != nil ? cancelButton : nil
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pageController.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = self.pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(item):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.peopleTableViewCell, for: indexPath)!
            
            configure(cell: cell, with: item)
            
            return cell
            
        case .loading:
            
            pageController.loadNextPage()
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.loadingTableViewCell, for: indexPath)!
            
            cell.activityIndicator.isHidden = false
            
            cell.activityIndicator.startAnimating()
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = self.pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(member):
            
            self.selectedMember(self, member)
            
        case .loading: break
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.search()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        self.scope = Scope(scopeIndex: selectedScope)!
        
        self.search()
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case R.segue.searchMembersViewController.showMemberDetail.identifier:
            
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            
            let data = self.pageController.items[indexPath.row]
            
            guard case let .item(member) = data else { fatalError("Invalid cell") }
            
            let memberProfileDetailViewController = segue.destination as! PersonDetailViewController
            
            memberProfileDetailViewController.profile = .member(member.identifier)
            
        default: fatalError("Unknown segue: \(segue)")
        }
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
