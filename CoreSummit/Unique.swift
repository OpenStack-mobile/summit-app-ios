//
//  Unique.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// A data type that can be uniquely identified.
public protocol Unique {
    
    var identifier: String { get }
}