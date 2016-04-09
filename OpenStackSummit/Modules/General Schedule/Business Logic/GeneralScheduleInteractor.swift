//
//  GeneralScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IGeneralScheduleInteractor: IScheduleInteractor {
    func isDataLoaded() -> Bool
    func isNetworkAvailable() -> Bool
    func checkForClearDataEvents()
}

public class GeneralScheduleInteractor: ScheduleInteractor, IGeneralScheduleInteractor {
        
    public func isNetworkAvailable() -> Bool {
        return reachability.isConnectedToNetwork()
    }
    
    public func checkForClearDataEvents() {
        dataUpdatePoller.clearDataIfTruncateEventExist()
    }
}
