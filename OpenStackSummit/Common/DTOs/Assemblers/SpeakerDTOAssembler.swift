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
    func createDTO(member: PresentationSpeaker) -> PresentationSpeakerDTO
}

public class SpeakerDTOAssembler: NSObject, ISpeakerDTOAssembler {
    public func createDTO(speaker: PresentationSpeaker) -> PresentationSpeakerDTO {
        let speakerDTO = PresentationSpeakerDTO()
        speakerDTO.id = speaker.id
        speakerDTO.name = speaker.firstName + " " + speaker.lastName
        return speakerDTO
    }
}
