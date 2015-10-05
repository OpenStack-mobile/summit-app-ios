//
//  PersonListDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class PersonListItemDTOAssembler: NSObject {
    public func createDTO<T: Person>(person: T)->PersonListItemDTO {
        let personListItemDTO = PersonListItemDTO()
        personListItemDTO.id = person.id
        personListItemDTO.name = person.firstName + " " + person.lastName
        personListItemDTO.title = person.title
        personListItemDTO.pictureUrl = person.pictureUrl
        personListItemDTO.isAttendee = person is SummitAttendee
        personListItemDTO.isSpeaker = person is PresentationSpeaker
        return personListItemDTO
    }
}

