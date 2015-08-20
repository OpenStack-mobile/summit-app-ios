//
//  DeserializationStorage.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public class DeserializerStorage: NSObject {
    var deserializedEntityDictionary = Dictionary<String, Dictionary<Int, BaseEntity>>()
    var realm = try! Realm()
    
    public func add<T : BaseEntity>(entity: T) {
        let className = _stdlib_getDemangledTypeName(entity)
        if (deserializedEntityDictionary[className] == nil) {
            deserializedEntityDictionary[className] = Dictionary<Int, T>()
        }
        NSLog("\(className)")
        deserializedEntityDictionary[className]![entity.id] = entity
    }
    
    public func get<T : BaseEntity>(id: Int) -> T {
        var entity: T?
        let className = _stdlib_getDemangledTypeName(T())
        entity = deserializedEntityDictionary[className]![id] as? T
        if (entity == nil) {
            entity = realm.objects(T.self).filter("id = \(id)").first
        }
        return entity!
    }
    
    public func getAll<T : BaseEntity>() -> [T] {
        let entity = T()
        let className = _stdlib_getDemangledTypeName(entity)
        NSLog("\(className)")
        
        var array = deserializedEntityDictionary[className]?.values.array as? [T]
        if (array == nil) {
            array = [T]()
        }
        return array!
    }
    
    public func exist<T : BaseEntity>(entity: T) -> Bool {
        let className = _stdlib_getDemangledTypeName(entity)
        return deserializedEntityDictionary[className]?[entity.id] != nil || realm.objects(T.self).filter("id = \(entity.id)").first != nil
    }

    public func clear() {
        deserializedEntityDictionary.removeAll()
    }
}
