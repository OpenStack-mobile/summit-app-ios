//
//  Page.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

/// Used for fetching requests that require paging.
public struct Page<Item: JSONDecodable> {
    
    public let currentPage: Int
    
    public let total: Int
    
    public let lastPage: Int
    
    public let perPage: Int
    
    public let items: [Item]
}
