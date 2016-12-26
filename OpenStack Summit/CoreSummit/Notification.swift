//
//  Notification.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct Notification {
    
    public let identifier: UUID
    
    public let date: Date
    
    public let message: String
    
    public let user: Identifier?
    
    public let group: Identifier
}