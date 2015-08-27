//
//  GeneralSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IGeneralScheduleFilterPresenter {
    func getFilterItems() -> [FilterSection]    
}

public class GeneralScheduleFilterPresenter: NSObject {
    
    var genereralScheduleFilterInteractor: IGeneralScheduleFilterInteractor!
    
    func getFilterItems() -> [FilterSection] {
        /*let summitTypes = genereralScheduleFilterInteractor.getSummitTypes()
        let eventTypes = genereralScheduleFilterInteractor.getEventTypes()
        let tracks = genereralScheduleFilterInteractor.getTracks()*/
        return [FilterSection]()
    }
}
