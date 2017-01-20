//
//  Profile.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit

/// Data type Used the configure the member profile-related View Controllers.
public enum MemberProfileIdentifier {
    
    case currentUser
    case speaker(Identifier)
    case member(Identifier)
    
    public init() {
        
        self = .currentUser
    }
    
    public init(speaker: Speaker) {
        
        self = .speaker(speaker.identifier)
    }
    
    public init(member: Member) {
        
        self = .member(member.identifier)
    }
}
