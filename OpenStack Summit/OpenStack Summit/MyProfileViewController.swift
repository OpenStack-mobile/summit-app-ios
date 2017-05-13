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
    
    var collectionViewFlowLayout: UICollectionViewLayout!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        super.viewDidLoad()
        
        title = "MY SUMMIT"
        
        reloadPagerTabStripView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateButtonBarViewLayout()
    }
    
    // MARK: - Private Methods
    
    private func updateButtonBarViewLayout() {
        
        guard buttonBarView != nil else { return }
        
        if collectionViewFlowLayout == nil {
            
            collectionViewFlowLayout = buttonBarView.collectionViewLayout
        }
        
        if Store.shared.authenticatedMember?.speakerRole != nil && self.view.frame.width <= 320 {
            
            buttonBarView.collectionViewLayout = collectionViewFlowLayout
            
        } else {
            
            buttonBarView.collectionViewLayout = KTCenterFlowLayout()
        }
    }
    
    // MARK: - PagerTabStripViewControllerDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var childViewControllers: [UIViewController] = [personDetailViewController]
        
        if let speaker = Store.shared.authenticatedMember?.speakerRole {
            
            let speakerPresentationsViewController = R.storyboard.schedule.speakerPresentationsViewController()!
            speakerPresentationsViewController.speaker = speaker.id
            childViewControllers.append(speakerPresentationsViewController)
        }
        
        childViewControllers += [personalScheduleViewController,
                                 favoriteEventsViewController]
        
        updateButtonBarViewLayout()
        
        return childViewControllers
    }
}
