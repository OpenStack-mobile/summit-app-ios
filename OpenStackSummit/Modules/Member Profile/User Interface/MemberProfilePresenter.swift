//
//  MemberProfilePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfilePresenter {
    var attendeeId: Int { get set }
    var speakerId: Int { get set }
    
    func viewLoad()
    func getChildViews() -> [UIViewController]
    func prepareForSpeakerProfile(speakerId: Int)
    func prepareForAttendeeProfile(attendeeId: Int)
    func prepareForMyProfile()
}

public class MemberProfilePresenter: NSObject, IMemberProfilePresenter {
    
    var interactor: IMemberProfileInteractor!
    var viewController: IMemberProfileViewController!

    var memberProfileDetailViewController: MemberProfileDetailViewController!
    var feedbackGivenListViewController: FeedbackGivenListViewController!
    var speakerPresentationsViewController: SpeakerPresentationsViewController!
    
    public var attendeeId = 0
    public var speakerId = 0
    
    public func prepareForSpeakerProfile(speakerId: Int) {
        self.speakerId = speakerId
        self.attendeeId = 0
    }

    public func prepareForAttendeeProfile(attendeeId: Int) {
        self.speakerId = 0
        self.attendeeId = attendeeId
    }

    public func prepareForMyProfile() {
        self.speakerId = 0
        self.attendeeId = 0
    }
    
    public func viewLoad() {
        if speakerId > 0 {
            interactor.getSpeakerProfile(speakerId) { speaker, error in
                if speaker != nil {
                    self.viewController.title = speaker!.name.uppercaseString
                }
            }
        }
    }
    
    public func getChildViews() -> [UIViewController] {
        var childViewController: [UIViewController] = []

        childViewController.append(memberProfileDetailViewController)
        
        if attendeeId > 0 {
            memberProfileDetailViewController.presenter.attendeeId = attendeeId
        }
        else if speakerId > 0 {
            memberProfileDetailViewController.presenter.speakerId = speakerId
            speakerPresentationsViewController.presenter.speakerId = speakerId
            childViewController.append(speakerPresentationsViewController)
        }
        
        return childViewController
    }
}