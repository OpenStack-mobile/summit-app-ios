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
    func getSummitTypesFromLocal() -> [SummitType]
}

public class SummitDataStore: GenericDataStore, ISummitDataStore {
    var summitRemoteDataStore: ISummitRemoteDataStore!
    
    public func getActive(completionBlock : (Summit?, NSError?) -> Void) {
        /*realm.write { () -> Void in
            self.realm.deleteAll()
        }*/
        let summit = realm.objects(Summit.self).first
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
            
            self.saveOrUpdateToLocal(summit!, completionBlock: completionBlock)
        }
    }
    
    public func getSummitTypesFromLocal() -> [SummitType] {
        let summitTypes = realm.objects(SummitType.self)
        return summitTypes.map { $0 }
    }
}
