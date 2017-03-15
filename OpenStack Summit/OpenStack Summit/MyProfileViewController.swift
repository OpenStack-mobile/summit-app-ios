//
//  MyProfileViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit
import KTCenterFlowLayout

final class MyProfileViewController: RevealTabStripViewController {
    
    // MARK: - Properties
    
    override var forwardChildBarButtonItems: Bool { return true }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        
        super.viewDidLoad()
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
        
        title = "MY SUMMIT"
        
        reloadPagerTabStripView()
    }
    
    // MARK: - PagerTabStripViewControllerDataSource
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var childViewControllers = [UIViewController]()
        
        let memberProfileDetailViewController = R.storyboard.member.personDetailViewController()!
        childViewControllers.append(memberProfileDetailViewController)
        
        if Store.shared.isLoggedInAndConfirmedAttendee {
            
            let personalScheduleViewController = R.storyboard.schedule.personalScheduleViewController()!
            childViewControllers.append(personalScheduleViewController)
        }
        
        let favoriteEventsViewController = R.storyboard.schedule.favoriteEventsViewController()!
        childViewControllers.append(favoriteEventsViewController)
        
        if let speaker = Store.shared.authenticatedMember?.speakerRole {
            
            let speakerPresentationsViewController = R.storyboard.schedule.speakerPresentationsViewController()!
            speakerPresentationsViewController.speaker = speaker.identifier
            childViewControllers.append(speakerPresentationsViewController)
        }
        
        return childViewControllers
    }
}
