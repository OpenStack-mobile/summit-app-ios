//
//  MyProfileInteractor.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation

@objc
public protocol IMyProfileInteractor {
    func getCurrentMember() -> MemberDTO?
}

public class MyProfileInteractor: NSObject, IMyProfileInteractor {
    
    var memberDTOAssembler: IMemberDTOAssembler!
    var securityManager: SecurityManager!
    
    public func getCurrentMember() -> MemberDTO? {
        var memberDTO: MemberDTO?
        if let member = securityManager.getCurrentMember() {
            memberDTO = memberDTOAssembler.createDTO(member)
        }
        return memberDTO
    }
    
}