//
//  InboxViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/26/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import XLPagerTabStrip
import KTCenterFlowLayout
import CoreSummit

final class InboxViewController: RevealTabStripViewController, RevealViewController {
    
    // MARK: - Properties
    
    override var forwardChildBarButtonItems: Bool { return true }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "INBOX"
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
        
        addMenuButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadPagerTabStripView()
    }
    
    // MARK: - RevealTabStripViewController
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var childViewControllers = [UIViewController]()
        
        let notificationsVC = R.storyboard.notifications.initialViewController()!
        
        childViewControllers.append(notificationsVC)
        
        if Store.shared.authenticatedMember != nil {
            
            let teamsVC = R.storyboard.teams.initialViewController()!
            
            childViewControllers.append(teamsVC)
        }
        
        return childViewControllers
    }
}
