//
//  MyScheduleDataUpdateStrategy.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class MyScheduleDataUpdateStrategy: DataUpdateStrategy {
    var memberDataStore: MemberDataStore!
    var securityManager: SecurityManager!
    
    public override init() {
        super.init()
    }
    
    public init(memberDataStore: MemberDataStore, securityManager: SecurityManager) {
        super.init()
        self.memberDataStore = memberDataStore
        self.securityManager = securityManager
    }
    
    public override func process(dataUpdate: DataUpdate) throws {
        let currentMember = securityManager.getCurrentMember()

        switch dataUpdate.operation! {
        case .Insert, .Update:
            try memberDataStore.addEventToMemberSheduleLocal(currentMember as Member!, event: dataUpdate.entity as! SummitEvent)
        case .Delete:
            try memberDataStore.removeEventFromMemberSheduleLocal(currentMember as Member!, event: dataUpdate.entity as! SummitEvent)
        }
    }
}
