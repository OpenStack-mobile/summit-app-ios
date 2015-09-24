//
//  MemberProfileInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfileInteractor {
    func getMember(memberId: Int, completionBlock : (MemberProfileDTO?, NSError?) -> Void)
    func requestFriendship(memberId: Int, completionBlock: (NSError?) -> Void)
    func isLoggedIn() -> Bool
}

public class MemberProfileInteractor: NSObject, IMemberProfileInteractor {
    var memberDataStore: IMemberDataStore!
    var memberProfileDTOAssembler: IMemberProfileDTOAssembler!
    var securityManager: SecurityManager!
    
    public override init() {
        super.init()
    }
    
    public init(memberDataStore: IMemberDataStore, securityManager: SecurityManager) {
        self.memberDataStore = memberDataStore
        self.securityManager = securityManager
    }
    
    public func getMember(memberId: Int, completionBlock : (MemberProfileDTO?, NSError?) -> Void) {
        memberDataStore.getById(memberId) { member, error in
            if (error == nil) {
                let showFullProfile = self.isFullProfileAllowed(member!)
                let memberProfileDTO = self.memberProfileDTOAssembler.createDTO(member!, full: showFullProfile)
                completionBlock(memberProfileDTO, error)
            }
        }
    }
    
    public func isFullProfileAllowed(member: Member) -> Bool {
        var allow = false
        if let currentMember = securityManager.getCurrentMember() {
            if (currentMember.id == member.id) {
                allow = true
            }
            else if (currentMember.isFriend(member)) {
                allow = true
            }
        }
        return allow
    }
    
    public func requestFriendship(memberId: Int, completionBlock: (NSError?) -> Void) {
        completionBlock(nil)
    }
    
    public func isLoggedIn() -> Bool {
        return securityManager.isLoggedIn()
    }
}
