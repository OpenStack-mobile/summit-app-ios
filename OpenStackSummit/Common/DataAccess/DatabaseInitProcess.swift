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

public class DatabaseInitProcess : NSObject {
    var deserializerFactory = DeserializerFactory()
    
    public func runAsync(){
        let json = "{\"summit\":{\"id\":1,\"name\":\"Tokio\",\"locations\":[{\"id\":1,\"name\":\"Grand Hotel\",\"address\":\"5th Avenue 4456\",\"lat\":\"45\",\"long\":\"33\",\"map\":\"http://map.com/image.jpg\",\"rooms\":[{\"id\":1,\"name\":\"room1\",\"capacity\":1000},{\"id\":2,\"name\":\"room2\",\"capacity\":1200}]}],\"companies\":[{\"id\":1,\"name\":\"company1\"},{\"id\":1,\"name\":\"company1\"}],\"summitTypes\":[{\"id\":1,\"name\":\"main\"},{\"id\":2,\"name\":\"design\"}],\"eventTypes\":[{\"id\":1,\"name\":\"keynote\"},{\"id\":2,\"name\":\"presentation\"},{\"id\":3,\"name\":\"expo\"},{\"id\":4,\"name\":\"breakout\"}],\"presentationCategories\":[{\"id\":1,\"name\":\"category1\"},{\"id\":2,\"name\":\"category2\"},{\"id\":3,\"name\":\"category3\"},{\"id\":4,\"name\":\"category4\"}],\"events\":[{\"id\":1,\"title\":\"test event\",\"description\":\"this is a test event\",\"start\":1439936384,\"end\":1439956384,\"eventType\":1,\"summitTypes\":[1,2],\"sponsors\":[2],\"presentationCategory\":3,\"location\":2}]}}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        
        let jsonObject = JSON(data: data!)
        let summit : Summit
        var deserializer : DeserializerProtocol!
        
        let realm = try! Realm()
        realm.write {
            realm.deleteAll()
        }
        
        deserializer = deserializerFactory.create(DeserializerFactories.Summit)
        summit = deserializer.deserialize(jsonObject["summit"]) as! Summit
        
        realm.write { () -> Void in
            realm.add(summit)
        }
    }
}
