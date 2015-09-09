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
    func getFeedback(feedbackId: Int) -> Feedback?
}

public class FeedbackEditInteractor: NSObject, IFeedbackEditInteractor {
    var feedbackDataStore: IFeedbackDataStore!
    
    public func getFeedback(feedbackId: Int) -> Feedback? {
        return feedbackDataStore.getById(feedbackId)
    }
}
