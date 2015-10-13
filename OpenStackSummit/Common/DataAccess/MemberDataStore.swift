//
//  MemberDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

@objc
public protocol IMemberDataStore {
    func getById(id: Int, completionBlock : (Member?, NSError?) -> Void)
    func getByIdLocal(id: Int) -> Member?
    func addEventToMemberShedule(member: Member, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void)
    func removeEventFromMemberShedule(member: Member, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void)
    func getLoggedInMemberOrigin(completionBlock : (Member?, NSError?) -> Void)
}

public class MemberDataStore: GenericDataStore, IMemberDataStore {
    
    var memberRemoteStorage: IMemberRemoteDataStore!
    
    public override init() {
        super.init()
    }
    
    public init(memberRemoteStorage: IMemberRemoteDataStore) {
        self.memberRemoteStorage = memberRemoteStorage
    }

    public func getById(id: Int, completionBlock : (Member?, NSError?) -> Void) {
        let member = realm.objects(Member.self).filter("id = \(id)").first
        if (member != nil) {
            completionBlock(member, nil)
        }
        else {
            getByIdAsync(id, completionBlock: completionBlock)
        }
    }

    private func getByIdAsync(id: Int, completionBlock : (Member?, NSError?) -> Void) {
        memberRemoteStorage.getById(id) { member, error in
            
            if (member != nil) {
                self.saveOrUpdateLocal(member!)  { member, error in
                    completionBlock(member, error)
                }
            }
            else {
                completionBlock(member, error)
            }
        }
    }

    public func addEventToMemberSheduleLocal(member: Member, event: SummitEvent) {
        
        self.realm.write {
            member.attendeeRole!.scheduledEvents.append(event)
        }
    }
    
    public func removeEventFromMemberSheduleLocal(member: Member, event: SummitEvent) throws {
        
        self.realm.write {
            let index = member.attendeeRole!.scheduledEvents.indexOf("id = %@", event.id)
            if (index != nil) {
                member.attendeeRole?.scheduledEvents.removeAtIndex(index!)
            }
        }
    }
    
    public func addEventToMemberShedule(member: Member, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void) {
        memberRemoteStorage.addEventToShedule(member.attendeeRole!.id, eventId: event.id) { error in
           
            if error != nil {
                return
            }
            
            self.addEventToMemberSheduleLocal(member, event: event)
            
            completionBlock(member, error)
        }
    }
    
    public func removeEventFromMemberShedule(member: Member, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void) {
        memberRemoteStorage.removeEventFromShedule(member.attendeeRole!.id, eventId: event.id) { error in
            var innerError = error
            
            defer { completionBlock(member, innerError) }
            
            if error != nil {
                return
            }
            
            do {
                try self.removeEventFromMemberSheduleLocal(member, event: event)
            }
            catch {
                innerError = NSError(domain: "There was an error removing event from member schedule", code: 1001, userInfo: nil)
            }
        }
    }
    
    public func getLoggedInMemberOrigin(completionBlock : (Member?, NSError?) -> Void)  {
        memberRemoteStorage.getLoggedInMember { member, error in
            
            if (error != nil) {
                completionBlock(member, error)
                return
            }
            
            self.saveOrUpdateLocal(member!)  { member, error in
                completionBlock(member, error)
            }
        }
    }
    
    public func getByIdLocal(id: Int) -> Member? {
        return super.getByIdLocal(id)
    }
}
