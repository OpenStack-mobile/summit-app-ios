//
//  ITrigger.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

@objc public enum TriggerTypes: Int {
    case Pre, Post
}

@objc public enum TriggerOperations: Int {
    case Read, Save, Delete
}

public protocol Trigger {

    func run(entity: RealmEntity, type: TriggerTypes, operation: TriggerOperations, completionBlock: () -> ())
}
