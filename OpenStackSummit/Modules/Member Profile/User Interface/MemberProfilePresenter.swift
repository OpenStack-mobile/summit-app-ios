//
//  MemberProfilePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation

@objc
public protocol IMemberProfilePresenter {
    var attendeeId: Int { get set }
    var speakerId: Int { get set }
    
    func viewLoad()
    func getChildViews() -> [AnyObject]
    func prepareForSpeakerProfile(speakerId: Int)
    func prepareForAttendeeProfile(attendeeId: Int)
    func prepareForMyProfile()
}

public class MemberProfilePresenter: NSObject, IMemberProfilePresenter {
    
    var viewController: IMemberProfileViewController!
    var interactor: IMemberProfileInteractor!

    var memberProfileDetailViewController: IMemberProfileDetailViewController!
    var feedbackGivenListViewController: IFeedbackGivenListViewController!
    var speakerPresentationsViewController: ISpeakerPresentationsViewController!
    
    public var attendeeId = 0
    public var speakerId = 0
    
    public func prepareForSpeakerProfile(speakerId: Int) {
        self.speakerId = speakerId
        self.attendeeId = 0
    }

    public func prepareForAttendeeProfile(attendeeId: Int) {
        self.speakerId = 0
        self.attendeeId = 1
    }

    public func prepareForMyProfile() {
        self.speakerId = 0
        self.attendeeId = 0
    }
    
    public func viewLoad() {
        if (speakerId > 0) {
            interactor.getSpeakerProfile(speakerId) { speaker, error in
                if speaker != nil {
                    self.viewController.title = speaker!.name.uppercaseString
                }
            }
        }
    }
    
    public func getChildViews() -> [AnyObject] {
        var childViewController: [AnyObject] = []

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