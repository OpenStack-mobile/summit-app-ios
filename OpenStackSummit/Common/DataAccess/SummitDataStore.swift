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

@objc
public protocol ISummitDataStore {
    func getActive(completionBlock : (Summit) -> Void)
    func getSummitTypes() -> [SummitType]
}

public class SummitDataStore: BaseDataStore<Summit>, ISummitDataStore {
    public typealias EntityType = Summit
    
    var deserializerFactory: DeserializerFactory!
    
    init(deserializerFactory: DeserializerFactory) {
        self.deserializerFactory = deserializerFactory
    }
    
    public func getActive(completionBlock : (EntityType) -> Void) {
        let summit = realm.objects(Summit.self).first
        if (summit != nil) {
            completionBlock(summit!)
        }
        else {
            getActiveAsync(completionBlock)
        }
    }
    
    func getActiveAsync(completionBlock : (result: EntityType) -> Void) {
        let json = "{\"id\":1,\"name\":\"Tokio\",\"locations\":[{\"id\":1,\"name\":\"Grand Hotel\",\"description\": \"Description for the hotel\", \"address\":\"5th Avenue 4456\",\"lat\":\"45\",\"long\":\"33\",\"maps\":[{\"id\": 1, \"url\":\"http://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-meridien-map-level01.png\"}, {\"id\": 2, \"url\": \"https://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-merdien-map-level02.png\"}],\"rooms\":[{\"id\":1,\"name\":\"room1\",\"capacity\":1000},{\"id\":2,\"name\":\"room2\",\"capacity\":1200}]}],\"companies\":[{\"id\":1,\"name\":\"company1\"},{\"id\":2,\"name\":\"company2\"}],\"summitTypes\":[{\"id\":1,\"name\":\"main\"},{\"id\":2,\"name\":\"design\"}],\"eventTypes\":[{\"id\":1,\"name\":\"keynote\"},{\"id\":2,\"name\":\"presentation\"},{\"id\":3,\"name\":\"expo\"},{\"id\":4,\"name\":\"breakout\"}],\"presentationCategories\":[{\"id\":1,\"name\":\"category1\"},{\"id\":2,\"name\":\"category2\"},{\"id\":3,\"name\":\"category3\"},{\"id\":4,\"name\":\"category4\"}],\"events\":[{\"id\":1,\"title\":\"test event\",\"description\":\"this is a test event\",\"start\":1439936384,\"end\":1439956384,\"eventType\":1,\"summitTypes\":[1,2],\"sponsors\":[2],\"presentationCategory\":3,\"location\":2},{\"id\":2,\"title\":\"test event 2\",\"description\":\"this is a test event 2\",\"start\":1439986384,\"end\":1439996384,\"eventType\":1,\"summitTypes\":[2],\"sponsors\":[1],\"location\":1}]}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        
        let jsonObject = JSON(data: data!)
        let summit : Summit
        var deserializer : IDeserializer!
        
        deserializer = deserializerFactory.create(DeserializerFactories.Summit)
        summit = deserializer.deserialize(jsonObject) as! Summit
        
        saveOrUpdate(summit, completionBlock: completionBlock)
    }
    
    public func getSummitTypes() -> [SummitType] {
        let summitTypes = realm.objects(SummitType.self)
        return summitTypes.map { $0 }
    }
}
