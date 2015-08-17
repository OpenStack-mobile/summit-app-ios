//
//  SummitGeoLocatedLocation.swift
//  
//
//  Created by Claudio on 8/12/15.
//
//

import Foundation
import RealmSwift

public class SummitGeoLocatedLocation: BaseEntity {
    
    public dynamic var summitLocation = SummitLocation()
    public dynamic var address = ""
    public dynamic var lat = ""
    public dynamic var long = ""
}
