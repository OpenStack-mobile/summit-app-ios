//
//  PresentationSpeakerRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IPresentationSpeakerRemoteDataStore {
    func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PresentationSpeaker]?, NSError?) -> Void)
}

public class PresentationSpeakerRemoteDataStore: NSObject {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    public func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PresentationSpeaker]?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current/speakers") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String
            let deserializer : IDeserializer!
            var innerError: NSError?
            var speakers: [PresentationSpeaker]?
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.PresentationSpeaker)
            
            do {
                speakers = try deserializer.deserializePage(json) as? [PresentationSpeaker]
            }
            catch {
                innerError = NSError(domain: "There was an error deserializing presentation speakers", code: 3001, userInfo: nil)
            }
            
            completionBlock(speakers, innerError)
        }
    }
}
