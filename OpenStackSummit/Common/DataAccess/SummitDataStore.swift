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
    func getActiveLocal() -> Summit?
    func getSummitTypesLocal() -> [SummitType]
}

public class SummitDataStore: GenericDataStore, ISummitDataStore {
    var summitRemoteDataStore: ISummitRemoteDataStore!
    
    public func getActive(completionBlock : (Summit?, NSError?) -> Void) {
        let summit = realm.objects(Summit.self).first
        if (summit != nil) {
            completionBlock(summit!, nil)
        }
        else {
            getActiveAsync(completionBlock)
        }
    }

    public func getActiveLocal() -> Summit? {
        let summit = realm.objects(Summit.self).first
        return summit
    }
    
    func getActiveAsync(completionBlock : (Summit?, NSError?) -> Void) {
        summitRemoteDataStore.getActive() { (summit, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            self.saveOrUpdateLocal(summit!, completionBlock: completionBlock)
        }
    }
    
    public func getSummitTypesLocal() -> [SummitType] {
        let summitTypes = realm.objects(SummitType.self)
        return summitTypes.map { $0 }
    }
}
