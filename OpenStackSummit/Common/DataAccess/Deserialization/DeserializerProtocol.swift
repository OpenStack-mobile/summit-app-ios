//
//  IDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import Crashlytics


public enum DeserializerError: ErrorType {
    case BadFormat(String)
    case EntityNotFound(String)
}

public protocol IDeserializer {
    func deserialize(json : JSON) throws -> BaseEntity
}

public extension IDeserializer {
    func deserialize(json: String)  throws -> BaseEntity {
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonObject = JSON(data: data!)
        return try deserialize(jsonObject)
    }

    func deserializeArray(json: String)  throws -> [BaseEntity] {
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonObject = JSON(data: data!)
        let array = try deserializeArray(jsonObject)
        return array
    }

    func deserializeArray(jsonObject : JSON)  throws -> [BaseEntity] {
        var array = [BaseEntity]()
        var entity: BaseEntity
        
        for (_, jsonElem) in jsonObject {
            do {
                entity = try deserialize(jsonElem)
                array.append(entity)
            }
            catch{
                let message = NSLocalizedString("error_processing_uptate", value: "\((error as NSError).localizedDescription) processing this update: \(jsonElem.rawString())", comment: "")
                let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey:  message]
                let err = NSError(domain: Constants.ErrorDomain, code: 13001, userInfo: userInfo)
                Crashlytics.sharedInstance().recordError(err)
                printerr(err.localizedDescription)
            }
        }
        
        return array
    }
    
    func deserializePage(json: String)  throws -> [BaseEntity] {
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonObject = JSON(data: data!)
        let array = try deserializeArray(jsonObject["data"])
        return array
    }
    
    func validateRequiredFields(fieldNames:[String], inJson json: JSON) throws {
        var missedFields = [String]()
        
        for fieldName in fieldNames {
            if (json[fieldName] == nil) {
                missedFields.append(fieldName)
            }
        }

        if (missedFields.count > 0) {
            let missedFieldsString = missedFields.joinWithSeparator(", ")
            let errorMessage = "\(self) Following fields are missed: \(missedFieldsString)"
            printerr(errorMessage)
            throw DeserializerError.BadFormat(errorMessage)
        }
    }
}