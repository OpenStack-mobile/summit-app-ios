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
        
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    // MARK: - Private Methods
    
    private func willLoadData() {
        
        if pageController.pages.isEmpty {
            
            showActivityIndicator()
        }
    }
    
    private func didLoadNextPage(response: ErrorValue<Page<TeamInvitation>>) {
        
        hideActivityIndicator()
        
        switch response {
            
        case let .Error(error):
            
            showErrorMessage(error as NSError)
            
        case let .Value(newPage):
            
            tableView.beginUpdates()
            
            
            
            tableView.endUpdates()
        }
    }
}
