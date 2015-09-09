//
//  GeneralScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IGeneralScheduleInteractor {
    func getScheduleEvents(completionBlock: ([SummitEvent]?, NSError?) -> Void)
}

public class GeneralScheduleInteractor: NSObject, IGeneralScheduleInteractor {
    var summitDataStore : ISummitDataStore!
    
    public func getScheduleEvents(completionBlock: ([SummitEvent]?, NSError?) -> Void){
        summitDataStore.getActive() { summit, error in
            completionBlock(summit!.events.map{$0}, nil)
        }
    }
}
