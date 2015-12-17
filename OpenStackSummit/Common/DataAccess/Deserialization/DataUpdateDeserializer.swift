//
//  DataUpdateDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class DataUpdateDeserializer: NSObject, IDeserializer {
    var deserializerFactory: DeserializerFactory!
    
    public init(deserializerFactory: DeserializerFactory) {
        self.deserializerFactory = deserializerFactory
    }
    
    public override init() {
        super.init()
    }
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        let className = json["class_name"].stringValue
        let dataUpdate = DataUpdate()
        dataUpdate.id = json["id"].intValue
        dataUpdate.entityClassName = className
        let operationType = json["type"]

        switch (operationType) {
        case "INSERT":
            dataUpdate.operation = DataOperation.Insert
        case "UPDATE":
            dataUpdate.operation = DataOperation.Update
        case "DELETE":
            dataUpdate.operation = DataOperation.Delete
        default:
            throw DeserializerError.BadFormat("Operation is not valid")
        }
        
        if let deserializer = try deserializerFactory.create(className) {
            dataUpdate.entity = operationType.stringValue != "DELETE" && className != "MySchedule"
                ? try deserializer.deserialize(json["entity"])
                : try deserializer.deserialize(json["entity_id"])
        }
        
        return dataUpdate
    }
}
