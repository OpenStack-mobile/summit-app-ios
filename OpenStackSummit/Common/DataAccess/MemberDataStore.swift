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
    func getByIdFromLocal(id: Int) -> Member?
    func addEventToMemberShedule(member: Member, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void)
    func getLoggedInMemberFromOrigin(completionBlock : (Member?, NSError?) -> Void)
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
                self.saveOrUpdateToLocal(member!)  { member, error in
                    completionBlock(member, error)
                }
            }
            else {
                completionBlock(member, error)
            }
        }
    }

    public func addEventToMemberSheduleToLocal(member: Member, event: SummitEvent) throws {
        
        try self.realm.write {
            member.attendeeRole!.scheduledEvents.append(event)
        }
    }
    
    public func removeEventToMemberSheduleToLocal(member: Member, event: SummitEvent) throws {
        
        try self.realm.write {
            let index = member.attendeeRole!.scheduledEvents.indexOf("id = %@", event.id)
            if (index != nil) {
                member.attendeeRole?.scheduledEvents.removeAtIndex(index!)
            }
        }
    }
    
    public func addEventToMemberShedule(member: Member, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void) {
        memberRemoteStorage.addEventToShedule(member.id, eventId: event.id) { error in
            var addEventError = error
            
            defer { completionBlock(member, addEventError) }
            
            if error != nil {
                return
            }
            
            do {
                try self.realm.write {
                    member.attendeeRole!.scheduledEvents.append(event)
                    self.realm.add(member, update: true)
                }
            }
            catch {
                addEventError = NSError(domain: "There was an error adding event to member schedule", code: 1001, userInfo: nil)
            }
       }
    }
    
    public func getLoggedInMemberFromOrigin(completionBlock : (Member?, NSError?) -> Void)  {
        memberRemoteStorage.getLoggedInMember { member, error in
            
            if (member != nil) {
                self.saveOrUpdateToLocal(member!)  { member, error in
                    completionBlock(member, error)
                }
            }
            else {
                completionBlock(member, error)
            }
        }
    }
    
    public func getByIdFromLocal(id: Int) -> Member? {
        return super.getByIdFromLocal(id)
    }
}
