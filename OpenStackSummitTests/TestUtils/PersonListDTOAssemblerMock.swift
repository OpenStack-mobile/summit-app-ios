//
//  PersonListDTOAssemblerMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class PersonListItemDTOAssemblerMock: PersonListItemDTOAssembler {
    var personListItemDTO: PersonListItemDTO
    
    init(personListItemDTO: PersonListItemDTO) {
        self.personListItemDTO = personListItemDTO
    }
    
    override func createDTO<T : Person>(person: T) -> PersonListItemDTO {
        return personListItemDTO
    }
}
