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
    
    public func getByIdLocal(id: Int) -> Member? {
        return super.getByIdLocal(id)
    }
}
