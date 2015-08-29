//
//  ITrigger.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc public enum TriggerTypes: Int {
    case Pre, Post
}

@objc public enum TriggerOperations: Int {
    case Read, Save, Delete
}

@objc
public protocol ITrigger {

    func run(entity: BaseEntity, type: TriggerTypes, operation: TriggerOperations, completionBlock : (() -> Void)!)
}
