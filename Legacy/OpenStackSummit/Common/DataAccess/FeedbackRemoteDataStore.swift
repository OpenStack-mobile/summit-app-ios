//
//  FeedbackRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreSummit

public protocol FeedbackRemoteDataStoreProtocol {
    
    func saveOrUpdate(feedback: RealmFeedback, completionBlock: ErrorValue<RealmFeedback> -> ())
}

public final class FeedbackRemoteDataStore {
    
    var httpFactory: HttpFactory!
    
    func aveOrUpdate(feedback: RealmFeedback, completionBlock: ErrorValue<RealmFeedback> -> ()) {
        
        let endpoint = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/events/\(feedback.event.id)/feedback"
        let http = httpFactory.create(HttpType.OpenIDJson)
        var jsonDictionary = [String:AnyObject]()
        jsonDictionary["rate"] = feedback.rate
        jsonDictionary["note"] = feedback.review
        jsonDictionary["owner_id"] = feedback.owner.id
        
        http.POST(endpoint, parameters: jsonDictionary, completionHandler: { (responseObject, error) in
            
            if (error != nil) {
                completionBlock(.Error(error!))
                return
            }
            
            let id = Int(responseObject as! String)!
            feedback.id = id
            completionBlock(.Value(feedback))
        })
    }
}
