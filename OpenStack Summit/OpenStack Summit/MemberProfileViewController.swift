//
//  MemberProfileViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

final class MemberProfileViewController: RevealTabStripViewController {
    
    // MARK: - Properties
    
    private(set) var profile: MemberProfile = .currentUser
    
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
        
        switch profile {
            
        case .currentUser: childViewControllers = [memberProfileDetailVC]
            
        case let .attendee(identifier):
        }
    }
}



extension MemberProfileViewController {
    
    enum Profile {
        
        case currentUser
        case attendee(Int)
        case speaker(Int)
    }
}