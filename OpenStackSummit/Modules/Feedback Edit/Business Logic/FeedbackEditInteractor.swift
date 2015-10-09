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
}

public class FeedbackEditInteractor: NSObject, IFeedbackEditInteractor {
    var feedbackDataStore: IFeedbackDataStore!
    var feedbackDTOAssembler: IFeedbackDTOAssembler!

    public func getFeedback(feedbackId: Int) -> FeedbackDTO? {
        let feedback = feedbackDataStore.getByIdLocal(feedbackId)
        let feedbackDTO = feedbackDTOAssembler.createDTO(feedback!)
        return feedbackDTO
    }
}
