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
        let endpoint = "https://testresource-server.openstack.org/api/v1/summits/current/events/\(feedback.event.id)/feedback"
        let http = httpFactory.create(HttpType.OpenID)
        http.POST(endpoint, parameters: ["feedback": feedback], completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let id = Int(responseObject as! String)!
            feedback.id = id
            completionBlock(feedback, error)
            
            // TODO: sebastian must agree POST format, is feedback related to attendee or member?
        })
    }
}
