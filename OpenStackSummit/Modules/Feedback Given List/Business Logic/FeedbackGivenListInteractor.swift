//
//  MyFeedbackInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackGivenListInteractor {
    func getLoggedMemberGivenFeedback() ->[FeedbackDTO]
}

public class FeedbackGivenListInteractor: NSObject, IFeedbackGivenListInteractor {
    var securityManager: SecurityManager!
    var feedbackDTOAssembler: IFeedbackDTOAssembler!
    
    public func getLoggedMemberGivenFeedback() ->[FeedbackDTO] {
        guard let member = securityManager.getCurrentMember() else {
            return [FeedbackDTO]()
        }

        guard let attendee = member.attendeeRole else {
            return [FeedbackDTO]()
        }
        
        var feedbackDTO: FeedbackDTO
        var dtos: [FeedbackDTO] = []
        for feedback in attendee.feedback.sorted("date", ascending: false) {
            feedbackDTO = feedbackDTOAssembler.createDTO(feedback)
            dtos.append(feedbackDTO)
        }
        return dtos
    }
}
