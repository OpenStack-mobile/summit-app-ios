//
//  VenueListItemDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class VenueListItemDTO: NamedDTO {
    public var address = ""
    public var lat: Double!
    public var long: Double!
    public var backgroundImageUrl: String?
}
