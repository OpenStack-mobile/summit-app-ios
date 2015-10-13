//
//  venueRoomDetailDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class VenueRoomDetailDTO: NamedDTO {
    public var capacity = 0
    public var events = [ScheduleItemDTO]()
    
}
