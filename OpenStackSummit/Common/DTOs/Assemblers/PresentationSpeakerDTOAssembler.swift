//
//  SpeakerDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IPresentationSpeakerDTOAssembler {
    func createDTO(member: PresentationSpeaker) -> PresentationSpeakerDTO
}

public class PresentationSpeakerDTOAssembler: NSObject, IPresentationSpeakerDTOAssembler {
    var personListItemDTOAssembler: PersonListItemDTOAssembler!
    
    public override init() {
        super.init()
    }

    public init(personListItemDTOAssembler: PersonListItemDTOAssembler) {
        self.personListItemDTOAssembler = personListItemDTOAssembler
    }
    
    public func createDTO(attendee: PresentationSpeaker) -> PresentationSpeakerDTO {
        let personListDTO = personListItemDTOAssembler.createDTO(attendee)
        let speakerDTO = PresentationSpeakerDTO()
        speakerDTO.id = personListDTO.id
        speakerDTO.name = personListDTO.name
        speakerDTO.title = personListDTO.title
        speakerDTO.pictureUrl = personListDTO.pictureUrl
        speakerDTO.isAttendee = personListDTO.isAttendee
        speakerDTO.isSpeaker = personListDTO.isSpeaker
        speakerDTO.location = attendee.location
        speakerDTO.email = attendee.email
        speakerDTO.twitter = attendee.twitter
        speakerDTO.irc = attendee.irc
        speakerDTO.bio = attendee.bio
        return speakerDTO
    }
}
