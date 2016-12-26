//
//  NotificationGroup.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct NotificationGroup: Named {
    
    public let identifier: Identifier
    
    public var name: String
}

public func == (lhs: NotificationGroup, rhs: NotificationGroup) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
}