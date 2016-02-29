//
//  DataUpdateDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import Crashlytics

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
        case "TRUNCATE":
            dataUpdate.operation = DataOperation.Truncate
        default:
            throw DeserializerError.BadFormat("Operation is not valid")
        }
        
        if dataUpdate.operation != DataOperation.Truncate {
            do {
                if let deserializer = try deserializerFactory.create(className) {
                    dataUpdate.entity = operationType.stringValue != "DELETE" && className != "MySchedule"
                        ? try deserializer.deserialize(json["entity"])
                        : try deserializer.deserialize(json["entity_id"])
                }
            }
            catch DeserializerError.EntityNotFound(let em) {
                let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey :  NSLocalizedString("Entity not found", value: em, comment: "")]
                let err = NSError(domain: Constants.ErrorDomain, code: 13001, userInfo: userInfo)
                Crashlytics.sharedInstance().recordError(err)
                print(em)
            }
        }
        
        return dataUpdate
    }
}
