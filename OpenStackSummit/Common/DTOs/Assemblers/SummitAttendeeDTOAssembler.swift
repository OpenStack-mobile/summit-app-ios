//
//  SummitAttendeeDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISummitAttendeeDTOAssembler {
    func createDTO(attendee: SummitAttendee) -> SummitAttendeeDTO
}

public class SummitAttendeeDTOAssembler: NSObject, ISummitAttendeeDTOAssembler {
    
    var personListItemDTOAssembler: PersonListItemDTOAssembler!
    
    public func createDTO(attendee: SummitAttendee) -> SummitAttendeeDTO {
        let personListDTO = personListItemDTOAssembler.createDTO(attendee)
        let attendeeDTO = SummitAttendeeDTO()
        attendeeDTO.id = personListDTO.id
        attendeeDTO.name = personListDTO.name
        attendeeDTO.title = personListDTO.title
        attendeeDTO.pictureUrl = personListDTO.pictureUrl
        attendeeDTO.isAttendee = personListDTO.isAttendee
        attendeeDTO.isSpeaker = personListDTO.isSpeaker
        attendeeDTO.bio = attendee.bio
        return attendeeDTO
    }
}
