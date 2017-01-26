//
//  EntityController.swift
//  CoreDataStruct
//
//  Created by Alsey Coleman Miller on 11/6/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

/// Observes a managed object and updates a ```CoreDataDecodable```.
public final class EntityController<Decodable: CoreDataDecodable> {
    
    // MARK: - Properties
    
    public let entityName: String
    
    public let context: NSManagedObjectContext
    
    public var identifier: (key: String, value: NSObject) {
        
        get { return self.privateController.identifier }
        
        set { self.privateController.identifier = newValue }
    }
    
    public var event = ManagedObjectObserverEvent<Decodable>()
    
    public var enabled: Bool {
        
        get { return self.privateController.enabled }
        
        set { self.privateController.delegate = self; self.privateController.enabled = newValue }
    }
    
    // MARK: - Private Properties
    
    private let privateController: PrivateEntityController
    
    // MARK: - Initialization
    
    public init(entityName: String, identifier: (key: String, value: NSObject), context: NSManagedObjectContext) {
        
        self.entityName = entityName
        self.context = context
        
        self.privateController = PrivateEntityController(entityName: entityName, identifier: identifier, context: context)
    }
}

// MARK: - Supporting Types

public struct ManagedObjectObserverEvent<Decodable: CoreDataDecodable> {
    
    public var updated: (Decodable) -> () = { _ in }
    
    public var deleted: () -> () = { _ in }
}

// MARK: - Private

@objc private final class PrivateEntityController: NSObject {
    
    let entityName: String
    
    let context: NSManagedObjectContext
    
    var identifier: (key: String, value: NSObject)
    
    weak var delegate: PrivateEntityControllerDelegate?
    
    var enabled: Bool = false {
        
        willSet {
            
            // only new values
            guard enabled != newValue else { return }
            
            if newValue {
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(objectsDidChange(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: context)
                
                self.update()
            }
            else {
                
                NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextObjectsDidChangeNotification, object: self.context)
            }
        }
    }
    
    deinit {
        
        enabled = false
    }
    
    init(entityName: String, identifier: (key: String, value: NSObject), context: NSManagedObjectContext) {
        
        self.entityName = entityName
        self.identifier = identifier
        self.context = context
    }
    
    func update() {
        
        guard let entity = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName[entityName]
            else { fatalError("Unknown entity: \(entityName)") }
        
        if let managedObject = try! context.find(entity, resourceID: self.identifier.value, identifierProperty: self.identifier.key) {
            
            self.delegate?.observer(self, managedObjectUpdated: managedObject)
            
        } else {
            
            self.delegate?.managedObjectDeletedForObserver(self)
        }
    }
    
    @objc func objectsDidChange(notification: NSNotification) {
        
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as! Set<NSManagedObject>? {
            
            for managedObject in updatedObjects {
                
                if managedObject.valueForKey(identifier.key) as? NSObject == identifier.value
                    && managedObject.entity.name! == self.entityName {
                        
                        self.delegate?.observer(self, managedObjectUpdated: managedObject)
                        
                        return
                }
            }
        }
        
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as! Set<NSManagedObject>? {
            
            for managedObject in deletedObjects {
                
                if managedObject.valueForKey(identifier.key) as? NSObject == identifier.value &&
                    managedObject.entity.name! == self.entityName {
                        
                        self.delegate?.managedObjectDeletedForObserver(self)
                        
                        return
                }
            }
        }
    }
}

private protocol PrivateEntityControllerDelegate: class {
    
    func observer(observer: PrivateEntityController, managedObjectUpdated managedObject: NSManagedObject)
    
    func managedObjectDeletedForObserver(observer: PrivateEntityController)
}

extension EntityController: PrivateEntityControllerDelegate {
    
    private func observer(observer: PrivateEntityController, managedObjectUpdated managedObject: NSManagedObject) {
        
        let managedObject = managedObject as! Decodable.ManagedObject
        
        let decodable = Decodable(managedObject: managedObject)
        
        self.event.updated(decodable)
    }
    
    private func managedObjectDeletedForObserver(observer: PrivateEntityController) {
        
        self.event.deleted()
    }
}
