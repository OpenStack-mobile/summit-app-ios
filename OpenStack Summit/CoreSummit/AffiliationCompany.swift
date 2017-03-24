//
//  AffiliationCompany.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 3/23/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

public struct AffiliationCompany: Named, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
}

// MARK: - Equatable

public func == (lhs: AffiliationCompany, rhs: AffiliationCompany) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
}
