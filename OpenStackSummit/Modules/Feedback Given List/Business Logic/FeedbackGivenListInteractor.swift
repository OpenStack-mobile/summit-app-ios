//
//  MyFeedbackInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol FeedbackGivenListInteractorProtocol {
    
    func getLoggedMemberGivenFeedback() ->[Feedback]
}

public final class FeedbackGivenListInteractor: FeedbackGivenListInteractorProtocol {
    
    var securityManager: SecurityManager!
    
    public func getLoggedMemberGivenFeedback() ->[Feedback] {
        
        guard let member = securityManager.getCurrentMember() else {
            return [Feedback]()
        }

        guard let attendee = member.attendeeRole else {
            return [Feedback]()
        }
        
        let realmEntities = attendee.feedback.sorted("date", ascending: false)
        
        return Feedback.from(realm: realmEntities)
    }
}
