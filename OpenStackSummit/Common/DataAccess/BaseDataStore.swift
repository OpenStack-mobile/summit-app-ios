//
//  BaseDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public class BaseDataStore<T : BaseEntity>: NSObject {
    var realm = try! Realm()
    var trigger: ITrigger!
    
    override init() {
        super.init()
    }
    
    public func get(id: Int) -> T? {
        let entity = realm.objects(T.self).filter("id = \(id)").first
        return entity
    }

    public func getAll() -> [T] {
        let entities = realm.objects(T.self)
        return entities.map { $0 }
    }
    
    public func saveOrUpdate(entity: T, completitionBlock: ((T) -> Void)!) {
        realm.write {
            self.realm.add(entity, update: true)
        }
        if (trigger != nil) {
            trigger.run(entity, type: TriggerTypes.Post, operation: TriggerOperations.Save) {
                () in
                
                if (completitionBlock != nil) {
                    completitionBlock(entity)
                }
            }
        }
        else {
            if (completitionBlock != nil) {
                completitionBlock(entity)
            }
        }
    }
    
    public func delete(entity: T, completitionBlock : ((Void) -> Void)!) {
        realm.write {
            self.realm.delete(entity)
        }
        if (trigger != nil) {
            trigger.run(entity, type: TriggerTypes.Post, operation: TriggerOperations.Delete) {
                () in
                
                if (completitionBlock != nil) {
                    completitionBlock()
                }
            }
        }
        else {
            if (completitionBlock != nil) {
                completitionBlock()
            }
        }
    }
}
