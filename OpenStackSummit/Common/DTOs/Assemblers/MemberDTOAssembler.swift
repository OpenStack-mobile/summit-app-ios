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
    var presentationSpeakerDTOAssembler: IPresentationSpeakerDTOAssembler!
    var summitAttendeeDTOAssembler: ISummitAttendeeDTOAssembler!
    
    public override init() {
        super.init()
    }
    
    public init(presentationSpeakerDTOAssembler: IPresentationSpeakerDTOAssembler, summitAttendeeDTOAssembler: ISummitAttendeeDTOAssembler) {
        self.presentationSpeakerDTOAssembler = presentationSpeakerDTOAssembler
        self.summitAttendeeDTOAssembler = summitAttendeeDTOAssembler
    }
    
    public func createDTO(member: Member)->MemberDTO {
        let memberDTO = MemberDTO()
        memberDTO.id = member.id
        memberDTO.attendeeRole = member.attendeeRole != nil ? summitAttendeeDTOAssembler.createDTO(member.attendeeRole!) : nil
        memberDTO.speakerRole = member.speakerRole != nil ? presentationSpeakerDTOAssembler.createDTO(member.speakerRole!) : nil
        return memberDTO
    }
}
