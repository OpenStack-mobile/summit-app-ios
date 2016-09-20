//
//  Observable.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public final class Observable<Value> {
    
    // MARK: - Properties
    
    public var value: Value {
        
        didSet {
            
            observers.forEach { $0.callback(value) }
        }
    }
    
    // MARK: - Private Properties
    
    private var observers = [Observer<Value>]()
    
    private var nextID = 1
    
    // MARK: - Initialization
    
    public init(_ value: Value) {
        
        self.value = value
    }
    
    // MARK: - Methods
    
    public func observe(observer: (Value) -> ()) -> Int {
        
        let identifier = nextID
        
        // create notification
        let observer = Observer(identifier: identifier, callback: observer)
        
        // increment ID
        nextID += 1
        
        // add to queue
        observers.append(observer)
        
        return identifier
    }
    
    public func remove(observer: Int) -> Bool {
        
        guard let index = observers.indexOf({ $0.identifier == observer })
            else { return false }
        
        observers.removeAtIndex(index)
        
        return true
    }
}

public extension Observable where Value: NilLiteralConvertible {
    
    convenience init() { self.init(nil) }
}

private struct Observer<Value> {
    
    let identifier: Int
    
    let callback: (Value) -> ()
    
    init(identifier: Int, callback: (Value) -> ()) {
        
        self.identifier = identifier
        self.callback = callback
    }
}
