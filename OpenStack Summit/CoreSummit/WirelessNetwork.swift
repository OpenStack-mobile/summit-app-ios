//
//  WirelessNetwork.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/6/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation

public struct WirelessNetwork: Named {
    
    public let identifier: Identifier
    
    public let name: String
    
    public let password: String
    
    public let descriptionText: String?
    
    public let summit: Identifier
}

// MARK: - Equatable

public func == (lhs: WirelessNetwork, rhs: WirelessNetwork) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.password == rhs.password
        && lhs.descriptionText == rhs.descriptionText
        && lhs.summit == rhs.summit
}
