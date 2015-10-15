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
    var httpFactory: HttpFactory!
    
    func saveOrUpdate(feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void) {
        let endpoint = "https://dev-resource-server/api/v1/summits/current/events/\(feedback.event.id)/feedback"
        let http = httpFactory.create(HttpType.OpenIDJson)
        var jsonDictionary = [String:AnyObject]()
        jsonDictionary["rate"] = feedback.rate
        jsonDictionary["note"] = feedback.review
        jsonDictionary["owner_id"] = feedback.owner.id
        
        http.POST(endpoint, parameters: jsonDictionary, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let id = Int(responseObject as! String)!
            feedback.id = id
            completionBlock(feedback, error)
        })
    }
}
