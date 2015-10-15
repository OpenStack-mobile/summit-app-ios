//
//  MemberRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import AeroGearHttp
import AeroGearOAuth2

@objc
public protocol IMemberRemoteDataStore {
    func addEventToShedule(attendeeId: Int, eventId: Int, completionBlock : (NSError?) -> Void)
    func removeEventFromShedule(attendeeId: Int, eventId: Int, completionBlock : (NSError?) -> Void)
    func getById(memberId: Int, completionBlock : (Member?, NSError?) -> Void)
    func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)
}

public class MemberRemoteDataStore: NSObject, IMemberRemoteDataStore {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    public override init() {
        super.init()
    }
    
    public init(deserializerFactory: DeserializerFactory ) {
        self.deserializerFactory = deserializerFactory
    }

    public func addEventToShedule(attendeeId: Int, eventId: Int, completionBlock : (NSError?) -> Void) {
        let endpoint = "https://testresource-server.openstack.org/api/v1/summits/current/attendees/\(attendeeId)/schedule/\(eventId)"
        let http = httpFactory.create(HttpType.OpenIDGetFormUrlEncoded)
        //json[""]
        http.POST(endpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(error)
                return
            }
            completionBlock(error)
        })
    }

    public func removeEventFromShedule(attendeeId: Int, eventId: Int, completionBlock : (NSError?) -> Void) {
        let endpoint = "https://testresource-server.openstack.org/api/v1/summits/current/attendees/\(attendeeId)/schedule/\(eventId)"
        let http = httpFactory.create(HttpType.OpenIDGetFormUrlEncoded)
        http.DELETE(endpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(error)
                return
            }
            completionBlock(error)
        })
    }
    
    public func getById(memberId: Int, completionBlock : (Member?, NSError?) -> Void) {
        let json = "{\"id\":1,\"name\":\"Enzo\",\"lastName\":\"Francescoli\",\"email\":\"enzo@riverplate.com\",\"scheduledEvents\":[1],\"bookmarkedEvents\":[2]}"
        
        let member : Member
        var deserializer : IDeserializer!
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.Member)
        member = try! deserializer.deserialize(json) as! Member
        
        completionBlock(member, nil)
    }
    
    public func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)  {
        let attendeeEndpoint = "https://testresource-server.openstack.org/api/v1/summits/current/attendees/me?expand=ticket_type,speaker,feedback"
        let http = httpFactory.create(HttpType.OpenIDGetFormUrlEncoded)
        http.GET(attendeeEndpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            if let json = responseObject as? String {
                let deserializer = self.deserializerFactory.create(DeserializerFactoryType.Member)
                let member = try! deserializer.deserialize(json) as! Member
                completionBlock(member, error)
            }
        })
    }
}
