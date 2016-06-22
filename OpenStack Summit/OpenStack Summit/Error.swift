//
//  Error.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

struct Error {
    
    static let domain = "org.openstack.ios.summit"
    
    static let getSpeakerProfile = NSError(domain: Error.domain, code: 9001, userInfo: [NSLocalizedDescriptionKey: "There was an error getting speaker data"])
}
