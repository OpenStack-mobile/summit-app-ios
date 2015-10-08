//
//  SummitAttendeeRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISummitAttendeeRemoteDataStore {
    func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([SummitAttendee]?, NSError?) -> Void)
    func getById(id: Int, completionBlock : (SummitAttendee?, NSError?) -> Void)
}

public class SummitAttendeeRemoteDataStore: NSObject, ISummitAttendeeRemoteDataStore {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    public func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([SummitAttendee]?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current/attendees") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String
            let deserializer : IDeserializer!
            var innerError: NSError?
            var attendees: [SummitAttendee]?
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.SummitAttendee)
            
            do {
                attendees = try deserializer.deserializePage(json) as? [SummitAttendee]
            }
            catch {
                innerError = NSError(domain: "There was an error deserializing summit attendees", code: 4001, userInfo: nil)
            }
            
            completionBlock(attendees, innerError)
        }
    }
    
    public func getById(id: Int, completionBlock : (SummitAttendee?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current/attendees/\(id)") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String
            let deserializer : IDeserializer!
            var innerError: NSError?
            var attendee: SummitAttendee?
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.SummitAttendee)
            
            do {
                attendee = try deserializer.deserialize(json) as? SummitAttendee
            }
            catch {
                innerError = NSError(domain: "There was an error deserializing summit attendee", code: 4002, userInfo: nil)
            }
            
            completionBlock(attendee, innerError)
        }
    }
}
