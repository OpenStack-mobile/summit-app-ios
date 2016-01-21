//
//  RealmFactory.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 1/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

@objc public enum RealmType: Int {
    case Latest, Migrated
}

public class RealmFactory: NSObject {
    var schemaMigration = SchemaMigration()
    
    func create() throws -> Realm {
        return try create(RealmType.Migrated)
    }
    
    func create(type: RealmType) throws -> Realm {
        var realm: Realm!
        
        if (type == RealmType.Migrated) {
            let configuration = Realm.Configuration(
                schemaVersion: schemaMigration.getSchemaVersion(),
                migrationBlock: schemaMigration.getMigrationBlock()
            )
            realm = try Realm(configuration: configuration)
        }
        else if (type == RealmType.Latest) {
            realm = try Realm()
        }
        
        return realm
    }
}