//
//  SummitDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import RealmSwift
import SwiftFoundation
import CoreSummit

public protocol SummitDataStoreProtocol {
    
    func getActiveLocal() -> RealmSummit?
    func getSummitTypesLocal() -> [RealmSummitType]
}

public final class SummitDataStore: GenericDataStore, SummitDataStoreProtocol {
    
    public let summitRemoteDataStore: SummitRemoteDataStore
    
    // MARK: - Initialization
    
    public init(summitRemoteDataStore: SummitRemoteDataStore) {
        
        self.summitRemoteDataStore = summitRemoteDataStore
    }
    
    // MARK: - Methods
    
    public func getActive(completion: ErrorValue<RealmSummit> -> ()) {
        
        if let summit = realm.objects(RealmSummit.self).first {
            
            completion(.Value(summit))
            return
        }
        
        getActiveAsync(completion)
    }

    public func getActiveLocal() -> RealmSummit? {
        
        return realm.objects(RealmSummit.self).first
    }
    
    // MARK: - Private Methods
    
    private func getActiveAsync(completion: ErrorValue<RealmSummit> -> ()) {
        
        summitRemoteDataStore.getActive() { [weak self] (response) in
            
            guard let store = self else { return }
            
            switch response {
                
            case let .Error(error):
                
                completion(.Error(error))
                
            case let .Value(value):
                
                var realmEntity: RealmSummit!
                
                try! store.realm.write { realmEntity = value.save(store.realm) }
                
                store.saveOrUpdateLocal(realmEntity, completion: completion)
            }
        }
    }
    
    public func getSummitTypesLocal() -> [RealmSummitType] {
                
        return realm.objects(RealmSummitType.self).map { $0 }
    }
}
