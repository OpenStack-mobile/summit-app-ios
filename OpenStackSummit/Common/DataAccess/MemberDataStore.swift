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
    func getByIdLocal(id: Int) -> Member?
    func getLoggedInMemberOrigin(completionBlock : (Member?, NSError?) -> Void)
    func getLoggedInMemberBasicInfoOrigin(completionBlock : (Member?, NSError?) -> Void)
    func getAttendeesForTicketOrderOrigin(orderNumber: String, completionBlock : ([NonConfirmedSummitAttendee]?, NSError?) -> Void)
    func selectAttendeeFromOrderListOrigin(orderNumber: String, externalAttendeeId: Int, completionBlock : (NSError?) -> Void)
}

public class MemberDataStore: GenericDataStore, IMemberDataStore {
    
    var memberRemoteStorage: IMemberRemoteDataStore!
    
    public override init() {
        super.init()
    }
    
    public init(memberRemoteStorage: IMemberRemoteDataStore) {
        self.memberRemoteStorage = memberRemoteStorage
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
    
    public func getLoggedInMemberBasicInfoOrigin(completionBlock : (Member?, NSError?) -> Void)  {
        memberRemoteStorage.getLoggedInMemberBasicInfo { member, error in
            completionBlock(member, error)
        }
    }
    
    
    public func getByIdLocal(id: Int) -> Member? {
        return super.getByIdLocal(id)
    }
    
    public func getAttendeesForTicketOrderOrigin(orderNumber: String, completionBlock : ([NonConfirmedSummitAttendee]?, NSError?) -> Void) {
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
