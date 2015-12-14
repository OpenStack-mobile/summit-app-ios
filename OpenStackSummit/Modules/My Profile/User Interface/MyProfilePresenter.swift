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
    func getChildViews() -> [AnyObject]
}

public class MyProfilePresenter: NSObject, IMyProfilePresenter {
    var memberProfileDetailViewController: IMemberProfileDetailViewController!
    var personalScheduleViewController: IScheduleViewController!
    var feedbackGivenListViewController: IFeedbackGivenListViewController!
    var speakerPresentationsViewController: ISpeakerPresentationsViewController!
    var securityManager: SecurityManager!

    public func getChildViews() -> [AnyObject] {
        var childViewController: [AnyObject] = []
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
