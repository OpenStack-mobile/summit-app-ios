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

final class MemberProfileViewController: RevealTabStripViewController {
    
    // MARK: - Properties
    
    private(set) var profile: MemberProfileIdentifier
    
    // MARK: - Initialization
    
    init(profile: MemberProfileIdentifier) {
        
        self.profile = profile
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Loading
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadPagerTabStripView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if case let .speaker(speakerID) = profile {
            
            getSpeakerProfile(speakerID) { speaker, error in
                
                if speaker != nil {
                    self.viewController.title = speaker!.name.uppercaseString
                }
            }
        }
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
    }
    
    // MARK: - Methods
    
    
    
    // MARK: - RevealTabStripViewController
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let childViewControllers: [UIViewController]
        
        let memberProfileDetailVC = R.storyboard.memberProfile.memberProfileDetailViewController()!
        
        memberProfileDetailVC.profile = profile
        
        childViewControllers.append(memberProfileDetailVC)
        
        if case let .speaker(identifier) = profile {
            
            let speakerPresentationsViewController = SpeakerPresentationsViewController()
        }
        
        switch profile {
            
        case .currentUser: childViewControllers = [memberProfileDetailVC]
            
        case let .attendee(identifier): childViewControllers = [memberProfileDetailVC]
            
        case let .speaker(identifier):
        }
    }
}
