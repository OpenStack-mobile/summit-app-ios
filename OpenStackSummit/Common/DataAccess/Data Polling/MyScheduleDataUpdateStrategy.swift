//
//  MyScheduleDataUpdateStrategy.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class MyScheduleDataUpdateStrategy: NSObject, IDataUpdateStrategy {
    var genericDataStore: GenericDataStore!
    var securityManager: SecurityManager!
    
    public func process(dataUpdate: DataUpdate) {
        let currentMember = securityManager.getCurrentMember()

        switch dataUpdate.operation! {
        case .Insert, .Update:
            currentMember?.attendeeRole?.scheduledEvents.append(dataUpdate.entity as! SummitEvent)
        case .Delete:
            let index = currentMember?.attendeeRole?.scheduledEvents.indexOf("id = %@", dataUpdate.entity.id)
            if (index != nil) {
                currentMember?.attendeeRole?.scheduledEvents.removeAtIndex(index!)
            }
        }
        genericDataStore.saveOrUpdateToLocal(currentMember as Member!, completionBlock: nil)
    }
}
