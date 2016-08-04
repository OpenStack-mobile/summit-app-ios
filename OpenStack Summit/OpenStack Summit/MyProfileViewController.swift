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

final class MyProfileViewController: RevealTabStripViewController {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        navigationController?.navigationBar.topItem?.title = "MY SUMMIT"
        
        reloadPagerTabStripView()
    }
    
    // MARK: - PagerTabStripViewControllerDataSource
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let personalScheduleViewController = R.storyboard.schedule.personalScheduleViewController()!
        let memberProfileDetailViewController = R.storyboard.member.memberProfileDetailViewController()!
        let feedbackGivenListViewController = R.storyboard.feedback.feedbackGivenListViewController()!
        
        var childViewControllers = [personalScheduleViewController,
                                    memberProfileDetailViewController,
                                    feedbackGivenListViewController]
        
        if let speaker = Store.shared.authenticatedMember?.speakerRole {
            
            let speakerPresentationsViewController = R.storyboard.schedule.speakerPresentationsViewController()!
            speakerPresentationsViewController.speaker = speaker.id
            childViewControllers.append(speakerPresentationsViewController)
        }
        
        return childViewControllers
    }
}
