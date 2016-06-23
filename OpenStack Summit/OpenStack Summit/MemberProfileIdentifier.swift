//
//  Profile.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct CoreSummit.PresentationSpeaker

/// Data type Used the configure the member profile-related View Controllers. 
public enum MemberProfileIdentifier {
    
    case currentUser
    case speaker(Int)
}


public extension MemberProfileIdentifier {
    
    /// Initialize from `PersonListItem`.
    init(listItem: PresentationSpeaker) {
        
        self = .speaker(listItem.identifier)
    }
}