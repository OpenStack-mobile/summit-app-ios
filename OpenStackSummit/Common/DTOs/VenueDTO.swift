//
//  VenueDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/22/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class VenueDTO: VenueListItemDTO {
    public var maps = [String]()
    public var images = [String]()
    public var rooms = [VenueRoomDTO]()
}
