//
//  ImageDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class ImageDeserializer: NSObject, IDeserializer {
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json : JSON) throws -> RealmEntity {        
        var image: Image
        
        if let imageId = json.int {
            guard let check: Image = deserializerStorage.get(imageId) else {
                throw DeserializerError.EntityNotFound("Image with id \(imageId) not found on deserializer storage")
            }
            image = check
            
        }
        else {
            try validateRequiredFields(["id"], inJson: json)
            
            image = Image()
            image.id = json["id"].intValue
            image.url = json["image_url"].string ?? ""
            
            //assert(!image.url.isEmpty)
        }
        
        return image
    }
}
