//
//  GeneralScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class GeneralScheduleInteractor: NSObject {
    var delegate : GeneralSchedulePresenter?
    
    var summitDataStore : SummitDataStore
    let summitDataStoreAssembly = SummitDataStoreAssembly().activate();
    
    override init() {
        summitDataStore = summitDataStoreAssembly.summitDataStore() as! SummitDataStore
    }
    
    func getScheduleEventsAsync(){
        if (delegate != nil) {
            summitDataStore.getActive(){
                (summit) in
                self.delegate?.reloadSchedule(summit.events.map{$0})
            }
        }
    }
}
