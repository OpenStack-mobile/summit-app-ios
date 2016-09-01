//
//  Context.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit

/// Class wrapper for configuring Interface Controllers with Swift data types. 
final class Context<T> {
    
    let value: T
    
    init(_ value: T) {
        
        self.value = value
    }
}

/// The local cached summit. 
var cachedSummit: Summit?