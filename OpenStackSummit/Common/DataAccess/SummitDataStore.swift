//
//  SummitDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

public protocol SummitDataStoreProtocol: DataStoreProtocol {
    
}

public class SummitDataStore: NSObject, SummitDataStoreProtocol {
    public typealias EntityType = Summit
    
    var realm = try! Realm()
    var deserializerFactory: DeserializerFactory!
    
    override init() {
        super.init()
    }
    
    init(deserializerFactory: DeserializerFactory ) {
        self.deserializerFactory = deserializerFactory
    }
    
    public func get(id: Int, completitionBlock : (EntityType) -> Void) {
        
    }
    
    public func getAll(completitionBlock : (Results<EntityType>) -> Void) {
        let summits = realm.objects(Summit.self)
        if (summits.count > 0) {
            completitionBlock(summits)
        }
        else {
            getAllAsync(completitionBlock)
        }
    }
    
    func getAllAsync(completitionBlock : (result: Results<EntityType>) -> Void) {
        let json = "{\"id\":1,\"name\":\"Tokio\",\"locations\":[{\"id\":1,\"name\":\"Grand Hotel\",\"address\":\"5th Avenue 4456\",\"lat\":\"45\",\"long\":\"33\",\"map\":\"http://map.com/image.jpg\",\"rooms\":[{\"id\":1,\"name\":\"room1\",\"capacity\":1000},{\"id\":2,\"name\":\"room2\",\"capacity\":1200}]}],\"companies\":[{\"id\":1,\"name\":\"company1\"},{\"id\":2,\"name\":\"company2\"}],\"summitTypes\":[{\"id\":1,\"name\":\"main\"},{\"id\":2,\"name\":\"design\"}],\"eventTypes\":[{\"id\":1,\"name\":\"keynote\"},{\"id\":2,\"name\":\"presentation\"},{\"id\":3,\"name\":\"expo\"},{\"id\":4,\"name\":\"breakout\"}],\"presentationCategories\":[{\"id\":1,\"name\":\"category1\"},{\"id\":2,\"name\":\"category2\"},{\"id\":3,\"name\":\"category3\"},{\"id\":4,\"name\":\"category4\"}],\"events\":[{\"id\":1,\"title\":\"test event\",\"description\":\"this is a test event\",\"start\":1439936384,\"end\":1439956384,\"eventType\":1,\"summitTypes\":[1,2],\"sponsors\":[2],\"presentationCategory\":3,\"location\":2},{\"id\":2,\"title\":\"test event 2\",\"description\":\"this is a test event 2\",\"start\":1439986384,\"end\":1439996384,\"eventType\":1,\"summitTypes\":[1,2],\"sponsors\":[1],\"location\":1}]}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        
        let jsonObject = JSON(data: data!)
        let summit : Summit
        var deserializer : DeserializerProtocol!
        
        let realm = try! Realm()
        deserializer = deserializerFactory.create(DeserializerFactories.Summit)
        summit = deserializer.deserialize(jsonObject) as! Summit
        
        realm.write { () -> Void in
            realm.add(summit)
        }
        
        let result = realm.objects(Summit.self)
        completitionBlock(result: result)
    }
    
    public func saveOrUpdate(entity: EntityType, completitionBlock : (EntityType) -> Void) {
        
    }
    
    public func delete(entity: EntityType, completitionBlock : () -> Void) {
        
    }
}
