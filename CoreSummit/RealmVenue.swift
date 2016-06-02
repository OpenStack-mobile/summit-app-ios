//
//  RealmVenue.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmVenue: RealmLocation {
    
    public dynamic var address = ""
    public dynamic var city = ""
    public dynamic var zipCode = ""
    public dynamic var state = ""
    public dynamic var country = ""
    public dynamic var lat = ""
    public dynamic var long = ""
    public dynamic var isInternal = true
    public let maps = List<RealmImage>()
    public let images = List<RealmImage>()
}
