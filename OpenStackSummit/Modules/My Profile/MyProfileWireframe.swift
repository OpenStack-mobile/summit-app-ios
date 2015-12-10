//
//  MyProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController
import XLPagerTabStrip

@objc
public protocol IMyProfileWireframe {
    var memberId: Int { get set }
    func presentMyProfileInterfaceFromRevealViewController(memberId: Int, revealViewController: SWRevealViewController)
}

class MyProfileWireframe: NSObject, IMyProfileWireframe, XLPagerTabStripViewControllerDataSource {
    var memberId: Int = 0
    
    var navigationController: UINavigationController!
    
    var memberProfileWireframe: MemberProfileWireframe!

    var myProfileViewController: MyProfileViewController!
    var personalScheduleViewController: PersonalScheduleViewController!
    var feedbackGivenListViewController: FeedbackGivenListViewController!
    
    func presentMyProfileInterfaceFromRevealViewController(memberId: Int, revealViewController: SWRevealViewController) {
        self.memberId = memberId
        myProfileViewController.dataSource = self
        myProfileViewController.presenter.memberId = memberId
        navigationController.setViewControllers([myProfileViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> [AnyObject] {
        var childViewController: [AnyObject] = []
        if memberId == 0 {
            childViewController.append(personalScheduleViewController)
        }
        childViewController.append(memberProfileWireframe.speakerProfileViewController(memberId))
        childViewController.append(feedbackGivenListViewController)
        return childViewController
    }
    
}
