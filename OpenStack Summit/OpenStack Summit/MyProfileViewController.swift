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
        
        let personalScheduleViewController = R.storyboard.schedule.personalScheduleViewController()!
        let memberProfileDetailViewController = R.storyboard.member.memberProfileDetailViewController()!
        let feedbackGivenListViewController = R.storyboard.feedback.feedbackGivenListViewController()!
        let favoriteEventsViewController = R.storyboard.schedule.favoriteEventsViewController()!
        
        var childViewControllers = [personalScheduleViewController,
                                    memberProfileDetailViewController,
                                    feedbackGivenListViewController,
                                    favoriteEventsViewController]
        
        if let speaker = Store.shared.authenticatedMember?.speakerRole {
            
            let speakerPresentationsViewController = R.storyboard.schedule.speakerPresentationsViewController()!
            speakerPresentationsViewController.speaker = speaker.identifier
            childViewControllers.append(speakerPresentationsViewController)
        }
        
        return childViewControllers
    }
}
