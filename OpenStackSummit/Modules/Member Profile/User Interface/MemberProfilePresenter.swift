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
    var speakerId: Int { get set }
    var attendeeId: Int { get set }
    
    func showMemberProfile()
    func prepareAttendeeProfile(attendeeId: Int)
    func prepareSpeakerProfile(speakerId: Int)
}

public class MemberProfilePresenter: NSObject, IMemberProfilePresenter {
    
    var memberProfileWireframe: IMemberProfileWireframe!
    var interactor: IMemberProfileInteractor!
    var viewController: IMemberProfileViewController!
    public var speakerId = 0
    public var attendeeId = 0
    
    public func prepareAttendeeProfile(attendeeId: Int) {
        self.attendeeId = attendeeId
        showMemberProfile()
    }
    
    public func prepareSpeakerProfile(speakerId: Int) {
        self.speakerId = speakerId
        showMemberProfile()
    }
    
    public func showMemberProfile() {
        
        if (speakerId > 0) {
            showSpeakerProfile()
        }
            
        else if (attendeeId > 0){
            showAttendeeProfile()
        }
        else {
            //TODO: handle error
        }
    }
    
    func showSpeakerProfile() {
        viewController.showActivityIndicator()        
        interactor.getSpeakerProfile(speakerId) { speaker, error in
            if (error != nil) {
                self.viewController.handlerError(error!)
                return
            }

            self.viewController.name = speaker!.name
            self.viewController.personTitle = speaker!.title
            self.viewController.hideActivityIndicator()
        }
    }
    
    func showAttendeeProfile() {
        viewController.showActivityIndicator()
        interactor.getAttendeeProfile(attendeeId) { attendee, error in
            if (error != nil) {
                self.viewController.handlerError(error!)
                return
            }

            self.viewController.name = attendee!.name
            self.viewController.personTitle = attendee!.title
            self.viewController.hideActivityIndicator()
        }
    }
    
    /*public func requestFriendship() {
        if (!interactor.isLoggedIn()) {
            memberProfileWireframe.showLoginView()
        }
        
        interactor.requestFriendship(memberId) { error in
            if (error != nil) {
                self.viewController.handlerError(error!)
                return
            }
            self.viewController.didFinishFriendshipRequest()
        }
    }*/
}