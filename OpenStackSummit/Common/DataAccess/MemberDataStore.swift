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
    func addEventToMemberShedule(memberId: Int, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void)
    func getLoggedInMemberFromOrigin(completionBlock : (Member?, NSError?) -> Void)
}

public class MemberDataStore: GenericDataStore, IMemberDataStore {
    
    var memberRemoteStorage: IMemberRemoteDataStore!
    
    override init() {
        super.init()
    }
    
    init(memberRemoteStorage: IMemberRemoteDataStore) {
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
    
    public func addEventToMemberShedule(memberId: Int, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void) {
        memberRemoteStorage.addEventToShedule(memberId, eventId: event.id) { error in
            var member: Member?
            var addEventError = error
            
            defer { completionBlock(member, addEventError) }
            
            if error != nil {
                return
            }
            
            member = self.realm.objects(Member.self).filter("id = \(memberId)").first!
            do {
                try self.realm.write {
                    member!.attendeeRole!.scheduledEvents.append(event)
                    self.realm.add(member!, update: true)
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
