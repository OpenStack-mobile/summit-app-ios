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
    func createDTO(member: PresentationSpeaker) -> SpeakerDTO
}

public class SpeakerDTOAssembler: NSObject, ISpeakerDTOAssembler {
    public func createDTO(speaker: PresentationSpeaker) -> SpeakerDTO {
        let speakerDTO = SpeakerDTO()
        speakerDTO.id = speaker.id
        speakerDTO.name = speaker.firstName + " " + speaker.lastName
        speakerDTO.isPresentationOwner = speaker.isPresentationOwner
        return speakerDTO
    }
}
