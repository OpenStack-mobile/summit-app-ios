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
    func addEventToShedule(memberId: Int, eventId: Int, completionBlock : (NSError?) -> Void)
    func getById(memberId: Int, completionBlock : (Member?, NSError?) -> Void)
    func getByEmail(email: String, completionBlock : (Member?, NSError?) -> Void)
    func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)
}

public class MemberRemoteDataStore: NSObject {
    var deserializerFactory: DeserializerFactory!
    var securityManager: SecurityManager!
    
    override init() {
        super.init()
    }
    
    init(deserializerFactory: DeserializerFactory ) {
        self.deserializerFactory = deserializerFactory
    }

    public func addEventToShedule(memberId: Int, eventId: Int, completionBlock : (NSError?) -> Void) {

        completionBlock(nil)
    }
    
    public func getById(memberId: Int, completionBlock : (Member?, NSError?) -> Void) {
        let json = "{\"id\":1,\"name\":\"Enzo\",\"lastName\":\"Francescoli\",\"email\":\"enzo@riverplate.com\",\"scheduledEvents\":[1],\"bookmarkedEvents\":[2]}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        
        let jsonObject = JSON(data: data!)
        let member : Member
        var deserializer : IDeserializer!
        
        deserializer = deserializerFactory.create(DeserializerFactories.Member)
        member = deserializer.deserialize(jsonObject) as! Member
        
        completionBlock(member, nil)
    }
    
    public func getByEmail(email: String, completionBlock : (Member?, NSError?) -> Void) {
        let json = "{\"id\":1,\"name\":\"Enzo\",\"lastName\":\"Francescoli\",\"email\":\"enzo@riverplate.com\",\"scheduledEvents\":[1],\"bookmarkedEvents\":[2]}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        
        let jsonObject = JSON(data: data!)
        let member : Member
        var deserializer : IDeserializer!
        
        deserializer = deserializerFactory.create(DeserializerFactories.Member)
        member = deserializer.deserialize(jsonObject) as! Member
        
        completionBlock(member, nil)
    }
    
    func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)  {
        let attendeeEndpoint = "https://testresource-server.openstack.org/api/v1/summits/current/attendees/me?expand=schedule,ticket_type,speaker"
        let http = Http(responseSerializer: StringResponseSerializer())
        http.authzModule = securityManager.oauthModuleOpenID
        http.GET(attendeeEndpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            if let json = responseObject as! NSString? {
                let data = json.dataUsingEncoding(NSUTF8StringEncoding)
                let jsonObject = JSON(data: data!)
                
                let deserializer = self.deserializerFactory.create(DeserializerFactories.Member)
                let member = deserializer.deserialize(jsonObject) as! Member
                completionBlock(member, error)
            }
        })
    }
}
