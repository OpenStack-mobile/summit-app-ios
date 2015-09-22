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
    func saveOrUpdate(entity: Feedback, completionBlock: ((Feedback?, NSError?) -> Void)!)
}

public class FeedbackDataStore: BaseDataStore<Feedback>, IFeedbackDataStore {
    var feedbackRemoteDataStore: IFeedbackRemoteDataStore!
    
    public func getByIdFromLocal(id: Int) -> Feedback? {
        return super.getById(id)
    }
    
    public override func saveOrUpdate(entity: Feedback, completionBlock: ((Feedback?, NSError?) -> Void)!) {
        feedbackRemoteDataStore.saveOrUpdate(entity, completionBlock: completionBlock)
    }
}
