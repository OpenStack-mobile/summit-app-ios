//
//  TeamMemberJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension TeamMember {
    
    enum JSONKey: String {
        
        case permission
    }
}

extension TeamMember: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let member = Member(
    }
}
