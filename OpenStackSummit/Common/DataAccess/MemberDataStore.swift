//
//  MemberDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

protocol IMemberDataStore : IDataStore {
    func getByEmail(email: NSString, completitionBlock : (Member?) -> Void)
}

public class MemberDataStore: BaseDataStore<Member>, IMemberDataStore {
    
    var deserializerFactory: DeserializerFactory!
    
    override init() {
        super.init()
    }
    
    init(deserializerFactory: DeserializerFactory ) {
        self.deserializerFactory = deserializerFactory
    }
    
    public func getByEmail(email: NSString, completitionBlock : (Member?) -> Void) {
        let member = realm.objects(Member.self).filter("email = '\(email)'").first
        if (member != nil) {
            completitionBlock(member)
        }
        else {
            getByEmailAsync(email, completitionBlock: completitionBlock)
        }
    }
    
    private func getByEmailAsync(email: NSString, completitionBlock : (Member) -> Void) {
        let json = "{\"id\":1,\"name\":\"Enzo\",\"lastName\":\"Francescoli\",\"email\":\"enzo@riverplate.com\",\"scheduledEvents\":[1],\"bookmarkedEvents\":[2]}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        
        let jsonObject = JSON(data: data!)
        let member : Member
        var deserializer : IDeserializer!
        
        let realm = try! Realm()
        deserializer = deserializerFactory.create(DeserializerFactories.Member)
        member = deserializer.deserialize(jsonObject) as! Member
        
        
        
        realm.write { () -> Void in
            realm.add(member)
        }
        
        completitionBlock(member)
    }
}
