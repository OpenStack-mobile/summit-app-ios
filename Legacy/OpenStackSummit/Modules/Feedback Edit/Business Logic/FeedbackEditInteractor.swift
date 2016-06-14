//
//  FeedbackEditInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackEditInteractor {
    func getFeedback(feedbackId: Int) -> FeedbackDTO?
    func saveFeedback(feedbackId: Int, rate: Int, review: String, eventId: Int, completionBlock: (FeedbackDTO?, NSError?) -> Void )
}

public class FeedbackEditInteractor: NSObject, IFeedbackEditInteractor {
    var summitAttendeeDataStore: ISummitAttendeeDataStore!
    var genericDataStore: GenericDataStore!
    var feedbackDTOAssembler: IFeedbackDTOAssembler!
    var securityManager: SecurityManager!
    var reachability: IReachability!
    
    public func getFeedback(feedbackId: Int) -> FeedbackDTO? {
        let feedback = genericDataStore.getByIdLocal(feedbackId) as! Feedback
        let feedbackDTO = feedbackDTOAssembler.createDTO(feedback)
        return feedbackDTO
    }
    
    public func saveFeedback(feedbackId: Int, rate: Int, review: String, eventId: Int, completionBlock: (FeedbackDTO?, NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Can't create feedback", code: 13002, userInfo: nil)
            completionBlock(nil, error)
            return
        }

        if let errorMessage = validateFeedback(rate, review: review) {
            let error = NSError(domain: errorMessage, code: 7001, userInfo: nil)
            completionBlock(nil, error)
            return
        }
        
        let member = securityManager.getCurrentMember()
        var feedback: Feedback
        if (feedbackId > 0) {
            feedback = genericDataStore.getByIdLocal(feedbackId) as! Feedback
        }
        else {
            feedback = Feedback()
            let event: SummitEvent? = genericDataStore.getByIdLocal(eventId)
            feedback.event = event!
            feedback.owner = member?.attendeeRole!
            feedback.date = NSDate()
        }
        feedback.rate = rate
        feedback.review = review ?? ""
        summitAttendeeDataStore.addFeedback(member!.attendeeRole!, feedback: feedback) {(feedback, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let feedbackDTO = self.feedbackDTOAssembler.createDTO(feedback!)
            completionBlock(feedbackDTO, error)
        }
    }
    
    func validateFeedback(rate: Int, review: String) -> String? {
        var errorMessage: String?
        if rate == 0 {
            errorMessage = "You must provide a rate using stars at the top"
        }
        else if review.isEmpty {
            errorMessage = "You must provide a review"
        }
        else if review.characters.count > 500 {
            errorMessage = "Review exceeded 500 characters limit"
        }
        return errorMessage;
    }
}
