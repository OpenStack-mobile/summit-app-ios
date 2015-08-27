//
//  Venue.swift
//  
//
//  Created by Claudio on 8/12/15.
//
//

import Foundation
import RealmSwift

public class Venue: SummitLocation {

    public dynamic var address = ""
    public dynamic var lat = ""
    public dynamic var long = ""
    public let maps = List<Image>()
    public let venueRooms = List<VenueRoom>()
}
