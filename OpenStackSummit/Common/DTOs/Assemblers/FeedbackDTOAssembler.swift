//
//  FeedbackDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackDTOAssembler {
    func createDTO(feedback: Feedback) -> FeedbackDTO
}

public class FeedbackDTOAssembler: NSObject, IFeedbackDTOAssembler {
    public func createDTO(feedback: Feedback) -> FeedbackDTO {
        let feedbackDTO = FeedbackDTO()
        feedbackDTO.id = feedback.id
        feedbackDTO.rate = feedback.rate
        feedbackDTO.review = feedback.review
        feedbackDTO.eventId = feedback.event.id
        feedbackDTO.eventName = feedback.event.name
        feedbackDTO.date = getDate(feedback)
        feedbackDTO.owner = feedback.owner.firstName + " " + feedback.owner.lastName
        
        return feedbackDTO
    }
    
    public func getDate(feedback: Feedback) -> String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE dd MMMM hh:mm a"
        let stringDate = dateFormatter.stringFromDate(feedback.date)
        
        return "\(stringDate)"
    }
}
