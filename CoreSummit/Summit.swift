//
//  Summit.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct Summit: Named {
    
    public let identifier: Int
    
    public var name: String
    
    public var startDate: Date
    
    public var endDate: Date
    
    public var initialDataLoadDate: Date
    
    public var timeZone: String
}


