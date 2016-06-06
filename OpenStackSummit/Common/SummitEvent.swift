//
//  SummitEvent.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreSummit

// MARK: - Realm

extension RealmSummitEvent {

    public var summit: RealmSummit {
        
        return try! RealmFactory().create().objects(RealmSummit).first!
    }
}