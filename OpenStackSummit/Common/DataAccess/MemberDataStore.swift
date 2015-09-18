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
    func getByEmail(email: String, completionBlock : (Member?, NSError?) -> Void)
    func addEventToMemberShedule(memberId: Int, event: SummitEvent, completionBlock : (Member?, NSError?) -> Void)
}

public class MemberDataStore: BaseDataStore<Member>, IMemberDataStore {
    
    var memberRemoteStorage: IMemberRemoteDataStore!
    
    override init() {
        super.init()
    }
    
    init(memberRemoteStorage: IMemberRemoteDataStore) {
        self.memberRemoteStorage = memberRemoteStorage
    }

    public func getById(id: Int, completionBlock : (Member?, NSError?) -> Void) {
        let member = realm.objects(Member.self).filter("id = '\(id)'").first
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
                self.saveOrUpdate(member!)  { member, error in
                    completionBlock(member, error)
                }
            }
            else {
                completionBlock(member, error)
            }
        }
    }
    
    public func getByEmail(email: String, completionBlock : (Member?, NSError?) -> Void) {
        let member = realm.objects(Member.self).filter("email = '\(email)'").first
        if (member != nil) {
            completionBlock(member, nil)
        }
        else {
            getByEmailAsync(email, completionBlock: completionBlock)
        }
    }
    
    private func getByEmailAsync(email: String, completionBlock : (Member?, NSError?) -> Void) {
        memberRemoteStorage.getByEmail(email) { member, error in
            
            if (member != nil) {
                self.saveOrUpdate(member!)  { member, error in
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
            if (error == nil) {
                member = self.realm.objects(Member.self).filter("id = \(memberId)").first!
                self.realm.write {
                    member!.attendeeRole!.scheduledEvents.append(event)
                    self.realm.add(member!, update: true)
                }
            }
            
            completionBlock(member, error)
        }
    }
}
