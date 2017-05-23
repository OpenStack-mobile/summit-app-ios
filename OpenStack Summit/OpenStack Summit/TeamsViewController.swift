//
//  TeamsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit
import XLPagerTabStrip
import JGProgressHUD

final class TeamsViewController: UITableViewController, PagingTableViewController, IndicatorInfoProvider, ContextMenuViewController {
    
    // MARK: - Properties
    
    lazy var pageController: PageController<Team> = PageController(fetch: { Store.shared.teams(page: $0.0, perPage: $0.1, completion: $0.2) })
    
    lazy var contextMenu: ContextMenu = {
        
        let createTeam = ContextMenu.Action(activityType: "\(type(of: self)).CreateTeam", image: nil, title: "Create Team", handler: .modal({ [weak self] (didComplete) -> UIViewController in
            
            let createTeamViewController = R.storyboard.teams.createTeamViewController()!
            
            createTeamViewController.completion = (
                done: { _ in didComplete(true); self?.refresh() },
                cancel: { _ in didComplete(false) }
            )
            
            let navigationController = UINavigationController(rootViewController: createTeamViewController)
            
            navigationController.modalPresentationStyle = .popover
            
            return navigationController
            }))
        
        let viewInvitations = ContextMenu.Action(activityType: "\(type(of: self)).TeamInvitations", image: nil, title: "View Invitations", handler: .modal({ [weak self] (didComplete) -> UIViewController in
            
            let teamInvitationsViewController = R.storyboard.teams.teamInvitationsViewController()!
            
            teamInvitationsViewController.completion = { _ in didComplete(true); self?.refresh() }
            
            let navigationController = UINavigationController(rootViewController: teamInvitationsViewController)
            
            navigationController.modalPresentationStyle = .pageSheet
            
            return navigationController
            }))
        
        return ContextMenu(actions: [createTeam, viewInvitations], shareItems: [], systemActions: false)
    }()
    
    private var unreadTeamMessagesObserver: Int?
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = unreadTeamMessagesObserver {
            
            PushNotificationManager.shared.unreadTeamMessages.remove(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addContextMenuBarButtonItem()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.loadingTableViewCell)
        
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        pageController.cached = { [weak self] in self?.loadFromCache() ?? [] }
        
        unreadTeamMessagesObserver = PushNotificationManager.shared.unreadTeamMessages
            .observe { [weak self] _ in self?.tableView.reloadData() }
        
        refresh()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.bringSubview(toFront: progressHUD)
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(_ sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    // MARK: - Private Methods
    
    private func loadFromCache() -> [Team] {
        
        return try! Team.all(Store.shared.managedObjectContext)
    }
    
    @inline(__always)
    private func configure(cell: TeamCell, with team: Team) {
        
        cell.nameLabel.text = team.name
        
        cell.descriptionLabel.text = team.descriptionText
        
        let unreadCount = try! PushNotificationManager.shared.unreadMessages(in: team.identifier, context: Store.shared.managedObjectContext)
        
        cell.unreadView.isHidden = unreadCount == 0
        cell.unreadLabel.text = "\(unreadCount)"
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Teams")
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pageController.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(item):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.teamCell)!
            
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
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case R.segue.teamsViewController.showTeamMessages.identifier:
            
            guard case let .item(selectedItem) = self.pageController.items[tableView.indexPathForSelectedRow!.row]
                else { fatalError("Invalid row") }
            
            let viewController = segue.destination as! TeamMessagesViewController
            
            viewController.team = selectedItem.identifier
            
        case R.segue.teamsViewController.showTeamDetail.identifier:
            
            guard case let .item(selectedItem) = self.pageController.items[tableView.indexPath(for: sender as! UITableViewCell)!.row]
                else { fatalError("Invalid row") }
            
            let viewController = segue.destination as! TeamDetailViewController
            
            viewController.team = selectedItem.identifier
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}

// MARK: - Supporting Types

final class TeamCell: UITableViewCell {
    
    @IBOutlet private(set) weak var nameLabel: UILabel!
    
    @IBOutlet private(set) weak var descriptionLabel: UILabel!
    
    @IBOutlet private(set) weak var unreadView: UIView!
    
    @IBOutlet private(set) weak var unreadLabel: UILabel!
}
