//
//  SummitDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

@objc
public protocol ISummitDataStore {
    func getActive(completionBlock : (Summit?, NSError?) -> Void)
    func getSummitTypes() -> [SummitType]
}

public class SummitDataStore: BaseDataStore<Summit>, ISummitDataStore {
    var summitRemoteDataStore: ISummitRemoteDataStore!
    
    public func getActive(completionBlock : (Summit?, NSError?) -> Void) {
        realm.write { () -> Void in
            self.realm.deleteAll()
        }
        var summit = realm.objects(Summit.self).first
        if (summit != nil) {
            completionBlock(summit!, nil)
        }
        else {
            getActiveAsync(completionBlock)
        }
    }
    
    func getActiveAsync(completionBlock : (Summit?, NSError?) -> Void) {
        summitRemoteDataStore.getActive() { (summit, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            self.saveOrUpdate(summit!, completionBlock: completionBlock)
        }
    }
    
    public func getSummitTypes() -> [SummitType] {
        let summitTypes = realm.objects(SummitType.self)
        return summitTypes.map { $0 }
    }
}
