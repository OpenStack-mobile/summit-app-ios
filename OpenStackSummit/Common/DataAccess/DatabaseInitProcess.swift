//
//  DatabaseInitializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class DatabaseInitProcess {
    var deserializerFactory = DeserializerFactory()
    
    public func runAsync(data: NSData) -> Summit{
        let json = JSON(data: data)
        let summit : Summit
        var deserializer : DeserializerProtocol!
        
        deserializer = deserializerFactory.create(DeserializerFactories.Summit)
        summit = deserializer.deserialize(json["summit"]) as! Summit
        return summit
    }
}
