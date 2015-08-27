//
//  GeneralScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IGeneralScheduleInteractor {
    func getScheduleEventsAsync()
}

public class GeneralScheduleInteractor: NSObject {
    var delegate : GeneralSchedulePresenter?
    
    var summitDataStore : ISummitDataStore!
    
    func getScheduleEventsAsync(){
        if (delegate != nil) {
            summitDataStore.getActive(){
                (summit) in
                self.delegate?.reloadSchedule(summit.events.map{$0})
            }
        }
    }
}
