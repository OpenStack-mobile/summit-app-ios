//
//  Venue.swift
//  
//
//  Created by Claudio on 8/12/15.
//
//

import Foundation
import RealmSwift

public class Venue: Location {

    public dynamic var address = ""
    public dynamic var city = ""
    public dynamic var zipCode = ""
    public dynamic var state = ""
    public dynamic var country = ""
    public dynamic var lat = ""
    public dynamic var long = ""
    public dynamic var isInternal = true
    public let maps = List<Image>()
    public let images = List<Image>()
    public let venueRooms = List<VenueRoom>()
}
