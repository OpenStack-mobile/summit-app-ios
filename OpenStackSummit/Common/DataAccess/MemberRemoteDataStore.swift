//
//  MemberRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc
public protocol IMemberRemoteDataStore {
    func addEventToShedule(memberId: Int, eventId: Int, completionBlock : (NSError?) -> Void)
    func getById(memberId: Int, completionBlock : (Member?, NSError?) -> Void)
    func getByEmail(email: String, completionBlock : (Member?, NSError?) -> Void)
}

public class MemberRemoteDataStore: NSObject {
    var deserializerFactory: DeserializerFactory!

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
}
