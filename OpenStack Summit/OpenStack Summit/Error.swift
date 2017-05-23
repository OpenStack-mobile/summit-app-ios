//
//  Error.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

struct AppError {
    
    static let domain = "org.openstack.ios.summit"
    
    static let getSpeakerProfile = NSError(domain: AppError.domain, code: 9001, userInfo: [NSLocalizedDescriptionKey: "There was an error getting speaker data"])
    
    static let getMemberProfile = NSError(domain: AppError.domain, code: 9001, userInfo: [NSLocalizedDescriptionKey: "There was an error getting member data"])
    
    static let reachability = NSError(domain: AppError.domain, code: 13002, userInfo: [NSLocalizedDescriptionKey: "There is no network connectivity."])
}
