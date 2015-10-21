//
//  EventRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventRemoteDataStore {
    func getFeedbackForEvent(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void)
}

public class EventRemoteDataStore: NSObject {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    public func getFeedbackForEvent(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current/events/\(eventId)/feedback?expand=owner&page=\(page)&per_page=\(objectsPerPage)") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String
            let deserializer : IDeserializer!
            var innerError: NSError?
            var feedbackList: [Feedback]?
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.Feedback)
            
            do {
                feedbackList = try deserializer.deserializePage(json) as? [Feedback]
            }
            catch {
                innerError = NSError(domain: "There was an error deserializing feedback for event with id \(eventId)", code: 5001, userInfo: nil)
            }
            
            completionBlock(feedbackList, innerError)
        }
        
    }
}
