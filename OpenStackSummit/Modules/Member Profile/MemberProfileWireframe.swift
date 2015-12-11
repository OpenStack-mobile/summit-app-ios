//
//  MemberProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController
import XLPagerTabStrip

@objc
public protocol IMemberProfileWireframe {
    var memberId: Int { get set }
    func presentMemberProfileInterfaceFromRevealViewController(memberId: Int, revealViewController: SWRevealViewController)
}

class MemberProfileWireframe: NSObject, IMemberProfileWireframe, XLPagerTabStripViewControllerDataSource {
    var memberId: Int = 0
    
    var navigationController: UINavigationController!
    
    var memberProfileDetailWireframe: MemberProfileDetailWireframe!
    
    var memberProfileViewController: MemberProfileViewController!
    var personalScheduleViewController: PersonalScheduleViewController!
    var feedbackGivenListViewController: FeedbackGivenListViewController!
    
    func presentMemberProfileInterfaceFromRevealViewController(memberId: Int, revealViewController: SWRevealViewController) {
        self.memberId = memberId
        memberProfileViewController.dataSource = self
        memberProfileViewController.presenter.memberId = memberId
        navigationController.setViewControllers([memberProfileViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> [AnyObject] {
        var childViewController: [AnyObject] = []
        // member == 0 means "Member profile"
        if memberId == 0 {
            childViewController.append(personalScheduleViewController)
        }
        childViewController.append(memberProfileDetailWireframe.speakerProfileViewController(memberId))
        childViewController.append(feedbackGivenListViewController)
        return childViewController
    }
    
}
