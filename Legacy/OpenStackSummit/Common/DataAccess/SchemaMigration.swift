//
//  SchemaMigration.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 1/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift
import CoreSummit

protocol ISchemaMigration {
    func getSchemaVersion() -> UInt64
    func getMigrationBlock() -> MigrationBlock
}

public class SchemaMigration: NSObject, ISchemaMigration {
    let schemaVersion:UInt64 = 10
    
    func getSchemaVersion() -> UInt64 {
        return schemaVersion
    }
    
    func getMigrationBlock() -> MigrationBlock {
        return { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
                migration.enumerate(RealmSummit.className()) { oldObject, newObject in
                    newObject!["trackGroups"] = List<RealmTrackGroup>()
                }
            }
            if (oldSchemaVersion < 2) {
                migration.enumerate(RealmSummitAttendee.className()) { oldObject, newObject in
                    let tickets = List<TicketType>()
                    if let ticketType = oldObject!["ticketType"] as? TicketType {
                        tickets.append(ticketType)
                        newObject!.delete("ticketType")
                    }
                    newObject!["tickets"] = tickets
                }
            }
            if (oldSchemaVersion < 3) {
                migration.enumerate(RealmTrackGroup.className()) { oldObject, newObject in
                    if let tracks = newObject!["tracks"] as? List<DynamicObject> {
                        for track in tracks {
                            track["trackGroup"] = newObject
                        }
                    }
                }
            }
            if (oldSchemaVersion < 4) {
                migration.enumerate(RealmDataUpdate.className()) { oldObject, newObject in
                    newObject!["operation"] = DataOperation.NoOp.rawValue
                }
            }
            if (oldSchemaVersion < 5) {
                migration.enumerate(RealmSummit.className()) { oldObject, newObject in
                    newObject!["startShowingVenuesDate"] = NSDate(timeIntervalSince1970: 1)
                }
            }
            if (oldSchemaVersion < 6) {
                migration.enumerate(RealmVenue.className()) { oldObject, newObject in
                    newObject!["images"] = List<Image>()
                }
            }
            if (oldSchemaVersion < 7) {
                migration.enumerate(RealmVenueRoom.className()) { oldVenueRoom, newVenueRoom in
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
                migration.enumerate(RealmSummit.className()) { oldObject, newObject in
                    newObject!["venuesRooms"] = List<RealmVenueRoom>()
                }
            }
            if (oldSchemaVersion < 9) {
                migration.enumerate(RealmSummitEvent.className()) { oldObject, newObject in
                    newObject!["averageFeedback"] = 0.0
                }
            }
            if (oldSchemaVersion < 10) {
                migration.enumerate(RealmTrackGroup.className()) { oldTrackGroup, newTrackGroup in
                    migration.enumerate(Track.className()) { oldTrack, newTrack in
                        if let trackGroup = oldTrack!["trackGroup"] as? DynamicObject {
                            if trackGroup["id"] as! Int == oldTrackGroup!["id"] as! Int {
                                let trackGroups = newTrack?["trackGroups"] as? List<DynamicObject>
                                trackGroups?.append(newTrackGroup!)
                                return
                            }
                        }
                    }
                }
            }
        }
    }
}