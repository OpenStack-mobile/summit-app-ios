//
//  MemberProfileViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import KTCenterFlowLayout
import CoreSummit

final class MemberProfileViewController: RevealTabStripViewController {
    
    // MARK: - Properties
    
    let profile: MemberProfileIdentifier
    
    // MARK: - Initialization
    
    init(profile: MemberProfileIdentifier = MemberProfileIdentifier()) {
        
        self.profile = profile
        
        super.init(nibName: nil, bundle: nil) // not created from NIB
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // try to get name if speaker
        if case let .speaker(speakerID) = profile {
            
            if let realmEntity = RealmPresentationSpeaker.find(speakerID, realm: Store.shared.realm) {
                
                let speaker = PresentationSpeaker(realmEntity: realmEntity)
                
                self.title = speaker.name.uppercaseString
                
                // set user activity for handoff
                let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
                userActivity.title = self.title
                userActivity.webpageURL = NSURL(string: "https://dev-openstack.org-site/summit/barcelona-2016/summit-schedule/speakers/\(speakerID)")
                
                userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue, AppActivityUserInfo.identifier.rawValue: speakerID]
                
                userActivity.becomeCurrent()
                
                self.userActivity = userActivity
            }
        }
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userActivity?.becomeCurrent()
        
        reloadPagerTabStripView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 9.0, *) {
            userActivity?.resignCurrent()
        }
    }
    
    // MARK: - Methods
    
    // MARK: - RevealTabStripViewController
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var childViewControllers = [UIViewController]()
        
        let memberProfileDetailVC = R.storyboard.member.memberProfileDetailViewController()!
        
        memberProfileDetailVC.profile = profile
        
        childViewControllers.append(memberProfileDetailVC)
        
        if case let .speaker(identifier) = profile {
            
            let speakerPresentationsViewController = R.storyboard.schedule.speakerPresentationsViewController()!
            
            // set speaker ID
            speakerPresentationsViewController.speaker = identifier
            
            childViewControllers.append(speakerPresentationsViewController)
        }
        
        return childViewControllers
    }
}
