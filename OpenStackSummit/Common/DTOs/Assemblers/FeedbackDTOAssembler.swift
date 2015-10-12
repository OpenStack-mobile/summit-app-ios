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
        return FeedbackDTO()
    }
}
