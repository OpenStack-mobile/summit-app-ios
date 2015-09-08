//
//  VenueRoomDetailDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueRoomDetailDTOAssembler {
    func createDTO(venueRoom: VenueRoom) -> VenueRoomDetailDTO
}

public class VenueRoomDetailDTOAssembler: NSObject {
    var scheduleItemDTOAssembler: ScheduleItemDTOAssembler!
    
    public func createDTO(venueRoom: VenueRoom) -> VenueRoomDetailDTO {
        let venueRoomDetailDTO = VenueRoomDetailDTO()
        venueRoomDetailDTO.name = venueRoom.name
        venueRoomDetailDTO.capacity = venueRoom.capacity
        
        var scheduleItemDTO: ScheduleItemDTO
        for event in venueRoom.events {
            scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
            venueRoomDetailDTO.events.append(scheduleItemDTO)
        }
        return venueRoomDetailDTO
    }
}
