//
//  FeedbackRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackRemoteDataStore {
    func saveOrUpdate(feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void)
}

public class FeedbackRemoteDataStore: NSObject {
    func saveOrUpdate(feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void) {
        completionBlock(feedback, nil)
    }
}
