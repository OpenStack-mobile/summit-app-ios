//
//  VenueTrigger.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Haneke

public class VenueTrigger: NSObject, ITrigger {
    public func run(entity: BaseEntity, type: TriggerTypes, operation: TriggerOperations, completitionBlock : ((Void) -> Void)!) {
        if (entity is Venue){
            run(entity as! Venue, type: type, operation: operation, completitionBlock : completitionBlock)
        }
        else {
            NSException(name: "InvalidArgument",reason: "entity is not of type Venue", userInfo: nil).raise()
        }
    }
    
    private func run(entity: Venue, type: TriggerTypes, operation: TriggerOperations, completitionBlock : ((Void) -> Void)!) {
        if (!entity.map.isEmpty) {
            Shared.imageCache.fetch(URL: NSURL(string: entity.map)!)
        }
    }
}
