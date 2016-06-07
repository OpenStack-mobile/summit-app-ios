//
//  MemberDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit
import RealmSwift

public protocol MemberDataStoreProtocol {
    func getByIdLocal(id: Int) -> RealmMember?
    func getLoggedInMemberOrigin(completionBlock: ErrorValue<RealmMember> -> ())
    func getLoggedInMemberBasicInfoOrigin(completionBlock: ErrorValue<RealmMember> -> ())
    func getAttendeesForTicketOrderOrigin(orderNumber: String, completionBlock: ErrorValue<[NonConfirmedSummitAttendee]> -> ())
    func selectAttendeeFromOrderListOrigin(orderNumber: String, externalAttendeeId: Int, completionBlock: (NSError?) -> ())
}

public class MemberDataStore: GenericDataStore, MemberDataStoreProtocol {
    
    let memberRemoteStorage: MemberRemoteDataStore
    
    public init(memberRemoteStorage: MemberRemoteDataStore) {
        self.memberRemoteStorage = memberRemoteStorage
    }
    
    public func getLoggedInMemberOrigin(completionBlock: ErrorValue<RealmMember> -> ())  {
        
        memberRemoteStorage.getLoggedInMember { member, error in
            
            guard error == nil
                else { completionBlock(.Error(error!)); return }
            
            if (error != nil) {
                completionBlock(member, error)
                return
            }
            
            self.saveOrUpdateLocal(member!)  { member, error in
                completionBlock(member, error)
            }
        }
    }
    
    public func getLoggedInMemberBasicInfoOrigin(completionBlock: ErrorValue<RealmMember> -> ())  {
        memberRemoteStorage.getLoggedInMemberBasicInfo { member, error in
            completionBlock(member, error)
        }
    }
    
    
    public func getByIdLocal(id: Int) -> RealmMember? {
        return super.getByIdLocal(id)
    }
    
    public func getAttendeesForTicketOrderOrigin(orderNumber: String, completionBlock: ErrorValue<[RealmNonConfirmedSummitAttendee]> -> ()) {
        memberRemoteStorage.getAttendeesForTicketOrder(orderNumber) { nonConfirmedAttendees, error in
            
            completionBlock(nonConfirmedAttendees, error)
        }
    }

    public func selectAttendeeFromOrderListOrigin(orderNumber: String, externalAttendeeId: Int, completionBlock : (NSError?) -> Void) {
        memberRemoteStorage.selectAttendeeFromOrderList(orderNumber, externalAttendeeId: externalAttendeeId) { error in
            completionBlock(error)
        }
    }
}
