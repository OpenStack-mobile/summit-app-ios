//
//  VenueRoomDTOAssemblerMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/22/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class VenueRoomDTOAssemblerMock: VenueRoomDTOAssembler {
    var venueRoomDTO: VenueRoomDTO
    
    init(venueRoomDTO: VenueRoomDTO) {
        self.venueRoomDTO = venueRoomDTO
    }
    
    override func createDTO(venueRoom: VenueRoom) -> VenueRoomDTO {
        return venueRoomDTO
    }
}
