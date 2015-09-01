//
//  SpeakerDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISpeakerDTOAssembler {
    func createDTO(member: Member) -> SpeakerDTO
}

public class SpeakerDTOAssembler: NSObject, ISpeakerDTOAssembler {
    public func createDTO(member: Member) -> SpeakerDTO {
        let speakerDTO = SpeakerDTO()
        speakerDTO.id = member.id
        speakerDTO.name = member.firstName + " " + member.lastName
        speakerDTO.isPresentationOwner = member.speakerRole!.isPresentationOwner
        return speakerDTO
    }
}
