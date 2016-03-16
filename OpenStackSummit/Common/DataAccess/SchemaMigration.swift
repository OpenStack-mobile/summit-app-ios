//
//  SchemaMigration.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 1/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

protocol ISchemaMigration {
    func getSchemaVersion() -> UInt64
    func getMigrationBlock() -> MigrationBlock
}

public class SchemaMigration: NSObject, ISchemaMigration {
    let schemaVersion:UInt64 = 8
    
    func getSchemaVersion() -> UInt64 {
        return schemaVersion
    }
    
    func getMigrationBlock() -> MigrationBlock {
        return { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
                migration.enumerate(Summit.className()) { oldObject, newObject in
                    newObject!["trackGroups"] = List<TrackGroup>()
                }
            }
            if (oldSchemaVersion < 2) {
                migration.enumerate(SummitAttendee.className()) { oldObject, newObject in
                    let tickets = List<TicketType>()
                    if let ticketType = oldObject!["ticketType"] as? TicketType {
                        tickets.append(ticketType)
                        newObject!.delete("ticketType")
                    }
                    newObject!["tickets"] = tickets
                }
            }
            if (oldSchemaVersion < 3) {
                migration.enumerate(TrackGroup.className()) { oldObject, newObject in
                    if let tracks = newObject!["tracks"] as? List<DynamicObject> {
                        for track in tracks {
                            track["trackGroup"] = newObject
                        }
                    }
                }
            }
            if (oldSchemaVersion < 4) {
                migration.enumerate(DataUpdate.className()) { oldObject, newObject in
                    newObject!["operation"] = DataOperation.NoOp.rawValue
                }
            }
            if (oldSchemaVersion < 5) {
                migration.enumerate(Summit.className()) { oldObject, newObject in
                    newObject!["startShowingVenuesDate"] = NSDate(timeIntervalSince1970: 1)
                }
            }
            if (oldSchemaVersion < 6) {
                migration.enumerate(Venue.className()) { oldObject, newObject in
                    newObject!["images"] = List<Image>()
                }
            }
            if (oldSchemaVersion < 7) {
                migration.enumerate(VenueRoom.className()) { oldVenueRoom, newVenueRoom in
                    migration.enumerate(Venue.className()) { oldVenue, newVenue in
                        let venueRooms = oldVenue!["venueRooms"] as? List<DynamicObject>
                        if venueRooms != nil {
                            for venueRoom in venueRooms! {
                                if (venueRoom["id"] as! Int == oldVenueRoom!["id"] as! Int) {
                                    newVenueRoom!["venue"] = newVenue
                                    return
                                }
                            }
                        }
                    }
                }
            }
            if (oldSchemaVersion < 8) {
                migration.enumerate(Summit.className()) { oldObject, newObject in
                    newObject!["venuesRooms"] = List<VenueRoom>()
                }
            }
        }
    }
}