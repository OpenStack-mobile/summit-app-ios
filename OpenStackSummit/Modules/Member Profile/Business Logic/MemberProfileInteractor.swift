//
//  MemberProfileInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfileInteractor: IBaseInteractor {
    func getCurrentMember() -> Member?
    func getMember(memberId: Int, completionBlock : (MemberProfileDTO?, NSError?) -> Void)
    func requestFriendship(memberId: Int, completionBlock: (NSError?) -> Void)
}

public class MemberProfileInteractor: BaseInteractor, IMemberProfileInteractor {
    var memberDataStore: IMemberDataStore!
    var memberProfileDTOAssembler: IMemberProfileDTOAssembler!

    public override init() {
        super.init()
    }
    
    public init(session: ISession, memberDataStore: IMemberDataStore) {
        super.init(session: session)
        self.memberDataStore = memberDataStore
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
        if let currentMember = getCurrentMember() as Member? {
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
}
