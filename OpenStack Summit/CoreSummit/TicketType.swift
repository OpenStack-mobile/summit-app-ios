//
//  TicketType.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct TicketType: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var allowedSummitTypes: [Identifier]
}