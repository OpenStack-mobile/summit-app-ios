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
    func getByIdFromLocal(id: Int) -> Feedback?
    func saveOrUpdateToLocal(entity: Feedback, completionBlock: ((Feedback?, NSError?) -> Void)!)
}

public class FeedbackDataStore: GenericDataStore, IFeedbackDataStore {
    var feedbackRemoteDataStore: IFeedbackRemoteDataStore!
    
    public func getByIdFromLocal(id: Int) -> Feedback? {
        return super.getByIdFromLocal(id)
    }
    
    public func saveOrUpdateToLocal(entity: Feedback, completionBlock: ((Feedback?, NSError?) -> Void)!) {
        feedbackRemoteDataStore.saveOrUpdate(entity, completionBlock: completionBlock)
    }
}
