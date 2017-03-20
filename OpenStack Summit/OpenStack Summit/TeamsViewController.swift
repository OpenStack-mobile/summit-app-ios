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
    
    lazy var pageController = PageController<Team>(fetch: { Store.shared.teams(page: $0.0, perPage: $0.1, completion: $0.2) })
    
    lazy var contextMenu: ContextMenu = {
        
        let createTeam = ContextMenu.Action(activityType: "\(self.dynamicType).CreateTeam", image: nil, title: "Create Team", handler: .modal({ [weak self] (didComplete) -> UIViewController in
            
            let createTeamViewController = R.storyboard.teams.createTeamViewController()!
            
            createTeamViewController.completion = (
                done: { _ in didComplete(true); self?.refresh() },
                cancel: { _ in didComplete(false) }
            )
            
            let navigationController = UINavigationController(rootViewController: createTeamViewController)
            
            navigationController.modalPresentationStyle = .Popover
            
            return navigationController
            }))
        
        let viewInvitations = ContextMenu.Action(activityType: "\(self.dynamicType).TeamInvitations", image: nil, title: "View Invitations", handler: .modal({ [weak self] (didComplete) -> UIViewController in
            
            let teamInvitationsViewController = R.storyboard.teams.teamInvitationsViewController()!
            
            teamInvitationsViewController.completion = { _ in didComplete(true); self?.refresh() }
            
            let navigationController = UINavigationController(rootViewController: teamInvitationsViewController)
            
            navigationController.modalPresentationStyle = .PageSheet
            
            return navigationController
            }))
        
        return ContextMenu(actions: [createTeam, viewInvitations], shareItems: [], systemActions: false)
    }()
    
    private var unreadTeamMessagesObserver: Int?
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .Dark)
    
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
        tableView.registerNib(R.nib.loadingTableViewCell)
        
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
        
        self.view.bringSubviewToFront(progressHUD)
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    // MARK: - Private Methods
    
    private func loadFromCache() -> [Team] {
        
        return try! Team.all(Store.shared.managedObjectContext)
    }
    
    @inline(__always)
    private func configure(cell cell: TeamCell, with team: Team) {
        
        cell.nameLabel.text = team.name
        
        cell.descriptionLabel.text = team.descriptionText
        
        let unreadCount = try! PushNotificationManager.shared.unreadMessages(in: team.identifier, context: Store.shared.managedObjectContext)
        
        cell.unreadView.hidden = unreadCount == 0
        cell.unreadLabel.text = "\(unreadCount)"
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Teams")
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pageController.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(item):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamCell)!
            
            configure(cell: cell, with: item)
            
            return cell
            
        case .loading:
            
            pageController.loadNextPage()
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.loadingTableViewCell, forIndexPath: indexPath)!
            
            cell.activityIndicator.hidden = false
            
            cell.activityIndicator.startAnimating()
            
            return cell
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case R.segue.teamsViewController.showTeamMessages.identifier:
            
            guard case let .item(selectedItem) = self.pageController.items[tableView.indexPathForSelectedRow!.row]
                else { fatalError("Invalid row") }
            
            let viewController = segue.destinationViewController as! TeamMessagesViewController
            
            viewController.team = selectedItem.identifier
            
        case R.segue.teamsViewController.showTeamDetail.identifier:
            
            guard case let .item(selectedItem) = self.pageController.items[tableView.indexPathForCell(sender as! UITableViewCell)!.row]
                else { fatalError("Invalid row") }
            
            let viewController = segue.destinationViewController as! TeamDetailViewController
            
            viewController.team = selectedItem.identifier
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}

// MARK: - Supporting Types

final class TeamCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var unreadView: UIView!
    
    @IBOutlet weak var unreadLabel: UILabel!
}
