//
//  DeserializationStorage.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class DeserializerStorage: NSObject {
    var deserializedEntityDictionary = Dictionary<String, Dictionary<Int, BaseEntity>>()

    public func add<T : BaseEntity>(entity: T) {
        let className = _stdlib_getDemangledTypeName(entity)
        if (deserializedEntityDictionary[className] == nil) {
            deserializedEntityDictionary[className] = Dictionary<Int, T>()
        }
        
        deserializedEntityDictionary[className]![entity.id] = entity
    }
    
    public func get<T : BaseEntity>(id: Int) -> T {
        let entity = T()
        let className = _stdlib_getDemangledTypeName(entity)
        
        return deserializedEntityDictionary[className]![id] as! T
    }
    
    public func getAll<T : BaseEntity>() -> [T] {
        let entity = T()
        let className = _stdlib_getDemangledTypeName(entity)
        
        return deserializedEntityDictionary[className]!.values.array as! [T]
    }
    
    public func exist<T : BaseEntity>(entity: T) -> Bool {
        let className = _stdlib_getDemangledTypeName(entity)
        //NSLog("\(deserializedEntityDictionary[entity.className])")
        NSLog("class name: \(className)")
        return deserializedEntityDictionary[className]?[entity.id] != nil
    }
}
