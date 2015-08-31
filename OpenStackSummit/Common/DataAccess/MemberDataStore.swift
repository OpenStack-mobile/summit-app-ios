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

@objc
protocol IMemberDataStore {
    func getByEmail(email: NSString, completionBlock : (Member?) -> Void)
    func addEventToMemberShedule(memberId: Int, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void)
}

public class MemberDataStore: BaseDataStore<Member>, IMemberDataStore {
    
    var deserializerFactory: DeserializerFactory!
    var remoteStorage: IMemberRemoteStorage!
    
    override init() {
        super.init()
    }
    
    init(deserializerFactory: DeserializerFactory ) {
        self.deserializerFactory = deserializerFactory
    }
    
    public func getByEmail(email: NSString, completionBlock : (Member?) -> Void) {
        let member = realm.objects(Member.self).filter("email = '\(email)'").first
        if (member != nil) {
            completionBlock(member)
        }
        else {
            getByEmailAsync(email, completionBlock: completionBlock)
        }
    }
    
    private func getByEmailAsync(email: NSString, completionBlock : (Member) -> Void) {
        let json = "{\"id\":1,\"name\":\"Enzo\",\"lastName\":\"Francescoli\",\"email\":\"enzo@riverplate.com\",\"scheduledEvents\":[1],\"bookmarkedEvents\":[2]}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        
        let jsonObject = JSON(data: data!)
        let member : Member
        var deserializer : IDeserializer!
        
        deserializer = deserializerFactory.create(DeserializerFactories.Member)
        member = deserializer.deserialize(jsonObject) as! Member
        
        saveOrUpdate(member, completionBlock: completionBlock)
    }
    
    public func addEventToMemberShedule(memberId: Int, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void) {
        remoteStorage.addEventToShedule(memberId, eventId: event.id) { error in
            var member: Member?
            if (error == nil) {
                member = self.realm.objects(Member.self).filter("id = \(memberId)").first!
                self.realm.write {
                    member!.scheduledEvents.append(event)
                    self.realm.add(member!, update: true)
                }
            }
            
            completionBlock(member, error)
        }
    }
}
