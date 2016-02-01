//
//  MyProfilePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMyProfilePresenter {
    func getChildViews() -> [UIViewController]
}

public class MyProfilePresenter: NSObject, IMyProfilePresenter {
    var securityManager: SecurityManager!
    var memberProfileDetailViewController: MemberProfileDetailViewController!
    var personalScheduleViewController: ScheduleViewController!
    var feedbackGivenListViewController: FeedbackGivenListViewController!
    var speakerPresentationsViewController: SpeakerPresentationsViewController!
    
    public func getChildViews() -> [UIViewController] {
        var childViewController: [UIViewController] = []
        
        childViewController.append(personalScheduleViewController)
        childViewController.append(memberProfileDetailViewController)
        childViewController.append(feedbackGivenListViewController)
        
        memberProfileDetailViewController.presenter.attendeeId = 0
        memberProfileDetailViewController.presenter.speakerId = 0
        
        if securityManager.getCurrentMemberRole() == MemberRoles.Speaker {
            childViewController.append(speakerPresentationsViewController)
        }

        return childViewController
    }
}
