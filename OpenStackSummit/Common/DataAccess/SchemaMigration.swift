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
    let schemaVersion:UInt64 = 2
    
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
        }
    }
}