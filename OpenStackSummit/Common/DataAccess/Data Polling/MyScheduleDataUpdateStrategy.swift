//
//  MyScheduleDataUpdateStrategy.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class MyScheduleDataUpdateStrategy: DataUpdateStrategy {
    var summitAttendeeDataStore: SummitAttendeeDataStore!
    var securityManager: SecurityManager!
    
    public override init() {
        super.init()
    }
    
    public init(summitAttendeeDataStore: SummitAttendeeDataStore, securityManager: SecurityManager) {
        super.init()
        self.summitAttendeeDataStore = summitAttendeeDataStore
        self.securityManager = securityManager
    }
    
    public override func process(dataUpdate: DataUpdate) throws {
        let currentMember = securityManager.getCurrentMember()

        switch dataUpdate.operation {
        case .Insert, .Update:
            summitAttendeeDataStore.addEventToMemberScheduleLocal(currentMember!.attendeeRole!, event: dataUpdate.entity as! SummitEvent)
        case .Delete:
            try summitAttendeeDataStore.removeEventFromMemberScheduleLocal(currentMember!.attendeeRole!, event: dataUpdate.entity as! SummitEvent)
        default:
            break
        }
    }
}
