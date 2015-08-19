//
//  GeneralSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class GeneralSchedulePresenter: NSObject {
    
    weak var viewController : GeneralScheduleViewController?
    var interactor : GeneralScheduleInteractor?
    var generalScheduleWireframe : GeneralScheduleWireframe?
    
    func reloadScheduleAsync() {
        self.interactor?.getScheduleEventsAsync()
    }
    
    func reloadSchedule(events: [SummitEvent]) {
        self.viewController?.events = events;
        self.viewController?.reloadSchedule()
    }
    
    func showEventDetail(eventId: Int) {
        self.generalScheduleWireframe?.showEventDetail(eventId)
    }
}
