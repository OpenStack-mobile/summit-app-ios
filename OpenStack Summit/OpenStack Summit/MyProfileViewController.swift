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
    
    lazy var personalScheduleViewController: PersonalScheduleViewController = R.storyboard.schedule.personalScheduleViewController()!
    lazy var favoriteEventsViewController: FavoriteEventsViewController = R.storyboard.schedule.favoriteEventsViewController()!
    lazy var personDetailViewController: PersonDetailViewController = R.storyboard.member.personDetailViewController()!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        
        super.viewDidLoad()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            buttonBarView.collectionViewLayout = KTCenterFlowLayout()
        }
        
        title = "MY SUMMIT"
        
        reloadPagerTabStripView()
    }
    
    // MARK: - Methods
    
    func showProfileDetail() {
        
        let _ = self.view
        
        moveToViewController(personDetailViewController, animated: true)
    }
    
    // MARK: - PagerTabStripViewControllerDataSource
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var childViewControllers = [personalScheduleViewController,
                                    favoriteEventsViewController,
                                    personDetailViewController]
        
        if let speaker = Store.shared.authenticatedMember?.speakerRole {
            
            let speakerPresentationsViewController = R.storyboard.schedule.speakerPresentationsViewController()!
            speakerPresentationsViewController.speaker = speaker.identifier
            childViewControllers.insert(speakerPresentationsViewController, atIndex: 0)
        }
        
        return childViewControllers
    }
}
