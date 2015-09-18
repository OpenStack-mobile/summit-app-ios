//
//  MemberDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberDTOAssembler {
    func createDTO(member: Member)->MemberDTO
}


public class MemberDTOAssembler: NSObject, IMemberDTOAssembler {
    public func createDTO(member: Member)->MemberDTO {
        let memberDTO = MemberDTO()
        memberDTO.id = member.id
        memberDTO.isAttendee = member.attendeeRole != nil
        memberDTO.isSpeaker = member.speakerRole != nil
        return memberDTO
    }
}
