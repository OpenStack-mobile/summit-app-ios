//
//  MemberProfileDetailPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

public protocol MemberProfileDetailPresenterProtocol {
    var speakerId: Int { get set }
    var attendeeId: Int { get set }
    
    func viewLoad()
}

public class MemberProfileDetailPresenter: MemberProfileDetailPresenterProtocol {
    
    var interactor: MemberProfileDetailInteractor!
    var viewController: IMemberProfileDetailViewController!
    
    var internalSpeakerId = 0
    var internalAttendeeId = 0
    
    public var speakerId: Int {
        get {
            return self.internalSpeakerId
        }
        set {
            self.internalSpeakerId = newValue
            self.internalAttendeeId = 0
        }
    }
    
    public var attendeeId: Int {
        get {
            return self.internalAttendeeId
        }
        set {
            self.internalAttendeeId = newValue
            self.internalSpeakerId = 0
        }
    }
    
    public func viewLoad() {
        self.viewController.showActivityIndicator()
        
        if speakerId > 0 {
            showSpeakerProfile()
        }
        else if attendeeId > 0 {
            showAttendeeProfile()
        }
        else {
            if let currentMember = interactor.getCurrentMember() {
                if currentMember.speakerRole != nil {
                    showPersonProfile(currentMember.speakerRole!, error: nil)
                }
                else {
                    showPersonProfile(currentMember.attendeeRole!, error: nil)
                }
            }
        }
    }
    
    func showSpeakerProfile() {
        self.interactor.getSpeakerProfile(self.speakerId) { speaker, error in
            self.showPersonProfile(speaker, error: error)
        }
    }
    
    func showAttendeeProfile() {
        self.interactor.getAttendeeProfile(self.attendeeId) { attendee, error in
            self.showPersonProfile(attendee, error: error)
        }
    }
    
    func showPersonProfile(value: ErrorValue<Person>) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            defer { self.viewController.hideActivityIndicator() }
            
            switch value {
                
            case let .Error(error):
                
                self.viewController.handlerError(error as NSError)
                self.viewController.hideActivityIndicator()
                
            case let .Value(person):
                
                self.viewController.name = person.name
                self.viewController.personTitle = person.title
                self.viewController.picUrl = person.pictureURL
                // FIXME: self.viewController.location =
                self.viewController.email = person.email
                self.viewController.twitter = person.twitter
                self.viewController.irc = person.irc
                self.viewController.bio = person.biography
            }
        })
    }
    
    /*public func requestFriendship() {
        interactor.requestFriendship(memberId) { error in
            if error != nil {
                self.viewController.handlerError(error!)
                return
            }
            self.viewController.didFinishFriendshipRequest()
        }
    }*/
}