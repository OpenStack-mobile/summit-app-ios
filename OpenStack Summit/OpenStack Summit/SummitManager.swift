//
//  SummitManager.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import Foundation
import CoreSummit

/// Manages the current summit being displayed in the UI
final class SummitManager {
    
    static let shared = SummitManager()
    
    // MARK: - Properties
    
    lazy var summit: Observable<Identifier> = self.initSummit()
    
    fileprivate let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    fileprivate init(userDefaults: UserDefaults = UserDefaults.standard) {
        
        self.userDefaults = userDefaults
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    fileprivate func initSummit() -> Observable<Identifier> {
        
        let summit = userDefaults.integer(forKey: PreferenceKey.summit.rawValue)
        
        let observable = Observable<Identifier>(summit)
        
        observable.observe(summitChanged)
        
        return observable
    }
    
    @inline(__always)
    fileprivate func summitChanged(_ newValue: Identifier, oldValue: Identifier) {
        
        userDefaults.setObject(newValue, forKey: PreferenceKey.summit.rawValue)
        userDefaults.synchronize()
    }
}

private extension SummitManager {
    
    enum PreferenceKey: String {
        
        case summit = "SummitManager.summit"
    }
}

extension UIViewController {
    
    var currentSummit: SummitManagedObject? {
        
        return try! SummitManagedObject.find(SummitManager.shared.summit.value, context: Store.shared.managedObjectContext)
    }
    
    var isDataLoaded: Bool {
        
        return self.currentSummit != nil
    }
}
