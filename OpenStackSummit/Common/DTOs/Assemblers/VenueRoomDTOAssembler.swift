//
//  VenueRoomDetailDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueRoomDTOAssembler {
    func createDTO(venueRoom: VenueRoom) -> VenueRoomDTO
}

public class VenueRoomDTOAssembler: NamedDTOAssembler, IVenueRoomDTOAssembler {
    var scheduleItemDTOAssembler: ScheduleItemDTOAssembler!
    
    public func createDTO(venueRoom: VenueRoom) -> VenueRoomDTO {
        let venueRoomDetailDTO: VenueRoomDTO = super.createDTO(venueRoom)

        if venueRoom.capacity > 0 {
            venueRoomDetailDTO.name += " - Capacity: \(venueRoom.capacity)"
        }
        
        var scheduleItemDTO: ScheduleItemDTO
        for event in venueRoom.events {
            scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
            venueRoomDetailDTO.events.append(scheduleItemDTO)
        }
        return venueRoomDetailDTO
    }
}
