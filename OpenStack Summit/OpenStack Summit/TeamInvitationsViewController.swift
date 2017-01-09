//
//  TeamInvitationsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftFoundation
import CoreSummit

final class TeamInvitationsViewController: UITableViewController, ShowActivityIndicatorProtocol, MessageEnabledViewController {
    
    // MARK: - Properties
    
    let pageController = PageController<TeamInvitation>(fetch: Store.shared.invitations)
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 98
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(R.nib.loadingTableViewCell)
        
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
        
    @IBAction func cancel(sender: AnyObject? = nil) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private Methods
    
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
    
    private func configure(cell cell: TeamInvitationTableViewCell, with invitation: TeamInvitation) {
        
        cell.teamLabel.text = invitation.team.name
        
        cell.inviterLabel.text = invitation.inviter.name
        
        cell.dateLabel.text = invitation.created.toFoundation().description
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
            
        case .loading:
            
            return tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.loadingTableViewCell)!
            
        case let .item(item):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamInvitationCell)!
            
            configure(cell: cell, with: item)
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
}

// MARK: - Supporting Types

final class TeamInvitationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var teamLabel: UILabel!
    
    @IBOutlet weak var inviterLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
}
