//
//  SummitManager.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit

/// Manages the current summit being displayed in the UI
final class SummitManager {
    
    static let shared = SummitManager()
    
    // MARK: - Properties
    
    lazy var summit: Observable<Identifier> = self.initSummit()
    
    private let userDefaults: NSUserDefaults
    
    // MARK: - Initialization
    
    private init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        
        self.userDefaults = userDefaults
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func initSummit() -> Observable<Identifier> {
        
        let summit = userDefaults.integerForKey(PreferenceKey.summit.rawValue)
        
        let observable = Observable<Identifier>(summit)
        
        observable.observe(summitChanged)
        
        return observable
    }
    
    @inline(__always)
    private func summitChanged(newValue: Identifier, oldValue: Identifier) {
        
        userDefaults.setObject(newValue, forKey: PreferenceKey.summit.rawValue)
        userDefaults.synchronize()
    }
}

private extension SummitManager {
    
    enum PreferenceKey: String {
        
        case summit = "SummitManager.summit"
    }
}

extension ViewController {
    
    var currentSummit: SummitManagedObject? {
        
        return try! SummitManagedObject.find(SummitManager.shared.summit.value, context: Store.shared.managedObjectContext)
    }
    
    var isDataLoaded: Bool {
        
        return self.currentSummit != nil
    }
}
