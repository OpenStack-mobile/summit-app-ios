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
    let schemaVersion:UInt64 = 1
    
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
        }
    }
}