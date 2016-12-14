//
//  TicketType.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct TicketType: Named, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
}

// MARK: - Equatable

public func == (lhs: TicketType, rhs: TicketType) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
}
