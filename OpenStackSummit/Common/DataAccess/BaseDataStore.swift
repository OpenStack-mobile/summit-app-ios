//
//  BaseDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public class BaseDataStore<T : BaseEntity>: NSObject {
    var realm = try! Realm()
    var trigger: ITrigger!
    
    override init() {
        super.init()
    }
    
    public func getById(id: Int) -> T? {
        let entity = realm.objects(T.self).filter("id = \(id)").first
        return entity
    }

    public func getAll() -> [T] {
        let entities = realm.objects(T.self)
        return entities.map { $0 }
    }
    
    public func saveOrUpdate(entity: T, completionBlock: ((T?, NSError?) -> Void)!) {

        do {
            try realm.write {
                self.realm.add(entity, update: true)
            }
        }
        catch {
            let error: NSError? = NSError(domain: "There was an error saving entity", code: 2000, userInfo: nil)
            completionBlock(nil, error)
        }
        
        if (trigger != nil) {
            trigger.run(entity, type: TriggerTypes.Post, operation: TriggerOperations.Save) {
                () in
                
                if (completionBlock != nil) {
                    completionBlock(entity, nil)
                }
            }
        }
        else {
            if (completionBlock != nil) {
                completionBlock(entity, nil)
            }
        }
    }
    
    public func delete(entity: T, completionBlock : (NSError? -> Void)!) {
        do {
            try realm.write {
                self.realm.delete(entity)
            }
        }
        catch {
            let error: NSError? = NSError(domain: "There was an error saving entity", code: 2000, userInfo: nil)
            completionBlock(error)
        }

        if (trigger != nil) {
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
}
