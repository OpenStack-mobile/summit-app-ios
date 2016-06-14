//
//  GenericDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit
import RealmSwift
import Crashlytics

public class GenericDataStore {
    
    internal let realm = try! RealmFactory().create()
    
    internal var trigger: Trigger?
    
    public func getByIdLocal<T: RealmEntity>(id: Int) -> T? {
        let entity = realm.objects(T.self).filter("id = \(id)").first
        return entity
    }

    public func getAllLocal<T: RealmEntity>() -> [T] {
        let entities = realm.objects(T.self)
        return entities.map { $0 }
    }
    
    public func saveOrUpdateLocal<T: RealmEntity>(entity: T, completion: ErrorValue<T> -> ()) {
        try! realm.write {
            self.realm.add(entity, update: true)
        }
        
        if let trigger = self.trigger {
            
            trigger.run(entity, type: TriggerTypes.Post, operation: TriggerOperations.Save) {
                
                completion(.Value(entity))
            }
            
        } else {
            
            completion(.Value(entity))
        }
    }
    
    public func deleteLocal<T: RealmEntity>(entity: T, completionBlock: (NSError? -> ())!) {
        
        try! realm.write {
            if entity.realm == realm {
                
                realm.delete(entity)
                
            } else {
                
                let message = NSLocalizedString("error_deleting_entity", value: "Entity \(entity.debugDescription) does not belongs to current Realm.", comment: "")
                let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey:  message]
                let err = NSError(domain: Constants.ErrorDomain, code: 20022, userInfo: userInfo)
                Crashlytics.sharedInstance().recordError(err)
                printdeb(err.localizedDescription)
            }
        }

        if let trigger = self.trigger {
            
            trigger.run(entity, type: TriggerTypes.Post, operation: TriggerOperations.Delete) {
                () in
                
                if (completionBlock != nil) {
                    completionBlock(nil)
                }
            }
        }
        else {
            if (completionBlock != nil) {
                completionBlock(nil)
            }
        }
    }
    
    public func clearDataLocal(completionBlock: (NSError? -> Void)!) {
        try! realm.write {
            self.realm.deleteAll()
        }
        
        if (completionBlock != nil) {
            completionBlock(nil)
        }
    }
}
