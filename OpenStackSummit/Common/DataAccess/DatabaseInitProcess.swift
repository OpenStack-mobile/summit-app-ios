//
//  DatabaseInitializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

public class DatabaseInitProcess {
    var deserializerFactory = DeserializerFactory()
    var realm = try! Realm()
    
    public func runAsync(data: NSData){
        let json = JSON(data: data)
        let summit : Summit
        var deserializer : DeserializerProtocol!
        
        realm.deleteAll()
        
        deserializer = deserializerFactory.create(DeserializerFactories.Summit)
        summit = deserializer.deserialize(json["summit"]) as! Summit
        
        realm.write { () -> Void in
            self.realm.add(summit)
        }
        
    }
}
