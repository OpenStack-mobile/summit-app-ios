//
//  FeedbackDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackDataStore {
    func getByIdLocal(id: Int) -> Feedback?
    func saveOrUpdateLocal(entity: Feedback, completionBlock: ((Feedback?, NSError?) -> Void)!)
}

public class FeedbackDataStore: GenericDataStore, IFeedbackDataStore {
    var feedbackRemoteDataStore: IFeedbackRemoteDataStore!
    
    public func getByIdLocal(id: Int) -> Feedback? {
        return super.getByIdLocal(id)
    }
    
    public func saveOrUpdateLocal(entity: Feedback, completionBlock: ((Feedback?, NSError?) -> Void)!) {
        feedbackRemoteDataStore.saveOrUpdate(entity, completionBlock: completionBlock)
    }
}
