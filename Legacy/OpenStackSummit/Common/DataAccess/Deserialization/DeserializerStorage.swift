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
    var deserializedEntityDictionary = Dictionary<String, Dictionary<Int, RealmEntity>>()
    var realm = try! Realm()
    
    public func add<T : RealmEntity>(entity: T) {
        let mirror = Mirror(reflecting: entity)
        let className = String(reflecting: mirror.subjectType)
        if (deserializedEntityDictionary[className] == nil) {
            deserializedEntityDictionary[className] = Dictionary<Int, T>()
        }
        deserializedEntityDictionary[className]![entity.id] = entity
    }
    
    public func get<T : RealmEntity>(id: Int) -> T? {
        var entity: T?
        let mirror = Mirror(reflecting: T())
        let className = String(reflecting: mirror.subjectType)
        entity = deserializedEntityDictionary[className]?[id] as? T
        if (entity == nil) {
            entity = realm.objects(T.self).filter("id = \(id)").first
        }
        return entity
    }
    
    public func getAll<T : RealmEntity>() -> [T] {
        let entity = T()
        let mirror = Mirror(reflecting: entity)
        let className = String(reflecting: mirror.subjectType)
        
        var array = [T]()
        if let values = deserializedEntityDictionary[className]?.values {
            for element in values {
                array.append(element as! T)
            }
        }

        return array
    }
    
    public func exist<T : RealmEntity>(entity: T) -> Bool {
        let mirror = Mirror(reflecting: entity)
        let className = String(reflecting: mirror.subjectType)
        return deserializedEntityDictionary[className]?[entity.id] != nil || realm.objects(T.self).filter("id = \(entity.id)").first != nil
    }

    public func clear() {
        deserializedEntityDictionary.removeAll()
    }
}
