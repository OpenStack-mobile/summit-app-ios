//
//  VenueManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class VenueManagedObject: LocationManagedObject {
    
    @NSManaged public var venueType: String
    
    @NSManaged public var locationType: String
    
    @NSManaged public var country: String
    
    @NSManaged public var address: String?
    
    @NSManaged public var city: String?
    
    @NSManaged public var zipCode: String?
    
    @NSManaged public var state: String?
    
    @NSManaged public var latitude: String?
    
    @NSManaged public var longitude: String?
    
    @NSManaged public var images: Set<ImageManagedObject>
    
    @NSManaged public var maps: Set<ImageManagedObject>
    
    @NSManaged public var floors: Set<VenueFloorManagedObject>
}

// MARK: - Encoding

extension Venue: CoreDataDecodable {
    
    public init(managedObject: VenueManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.type = ClassName(rawValue: managedObject.venueType)!
        self.locationType = LocationType(rawValue: managedObject.locationType)!
        self.country = managedObject.country
        self.address = managedObject.address
        self.city = managedObject.city
        self.zipCode = managedObject.zipCode
        self.latitude = managedObject.latitude
        self.longitude = managedObject.longitude
        self.state = managedObject.state
        self.images = Image.from(managedObjects: managedObject.images)
        self.maps = Image.from(managedObjects: managedObject.maps)
        self.floors = VenueFloor.from(managedObjects: managedObject.floors)
    }
}

extension Venue: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> VenueManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.venueType = type.rawValue
        managedObject.locationType = locationType.rawValue
        managedObject.country = country
        managedObject.address = address
        managedObject.city = city
        managedObject.zipCode = zipCode
        managedObject.state = state
        managedObject.latitude = latitude
        managedObject.longitude = longitude
        managedObject.images = try context.relationshipFault(images)
        managedObject.maps = try context.relationshipFault(maps)
        managedObject.floors = try context.relationshipFault(floors)
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension VenueManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}
