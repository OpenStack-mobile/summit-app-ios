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
    
    public var inserted: (Decodable) -> () = { _ in }
    
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
                
                NotificationCenter.default.addObserver(self, selector: #selector(objectsDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
                
                self.update()
            }
            else {
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: self.context)
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
            
            self.delegate?.managedObjectDeleted(for: self)
        }
    }
    
    @objc func objectsDidChange(_ notification: Foundation.Notification) {
        
        func filter(managedObject: NSManagedObject) -> Bool {
            
            return managedObject.value(forKey: identifier.key) as? NSObject == identifier.value
                && managedObject.entity.name! == self.entityName
        }
        
        let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as! Set<NSManagedObject>? ?? []
        
        if let managedObject = insertedObjects.first(where: filter) {
            
            self.delegate?.observer(self, managedObjectInserted: managedObject)
        }
        
        let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as! Set<NSManagedObject>? ?? []
        
        if let managedObject = updatedObjects.first(where: filter) {
            
            self.delegate?.observer(self, managedObjectUpdated: managedObject)
        }
        
        let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as! Set<NSManagedObject>? ?? []
        
        if deletedObjects.contains(where: filter) {
            
            self.delegate?.managedObjectDeleted(for: self)
        }
    }
}

private protocol PrivateEntityControllerDelegate: class {
    
    func observer(_ observer: PrivateEntityController, managedObjectUpdated managedObject: NSManagedObject)
    
    func observer(_ observer: PrivateEntityController, managedObjectInserted managedObject: NSManagedObject)
    
    func managedObjectDeleted(for observer: PrivateEntityController)
}

extension EntityController: PrivateEntityControllerDelegate {
    
    fileprivate func observer(_ observer: PrivateEntityController, managedObjectInserted managedObject: NSManagedObject) {
        
        let managedObject = managedObject as! Decodable.ManagedObject
        
        let decodable = Decodable(managedObject: managedObject)
        
        self.event.inserted(decodable)
    }
    
    fileprivate func observer(_ observer: PrivateEntityController, managedObjectUpdated managedObject: NSManagedObject) {
        
        let managedObject = managedObject as! Decodable.ManagedObject
        
        let decodable = Decodable(managedObject: managedObject)
        
        self.event.updated(decodable)
    }
    
    fileprivate func managedObjectDeleted(for observer: PrivateEntityController) {
        
        self.event.deleted()
    }
}
