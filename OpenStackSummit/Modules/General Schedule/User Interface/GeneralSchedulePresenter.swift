//
//  GeneralSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import MTDates

extension Array where Element: SummitEvent {
    func filter(byDate date: NSDate) -> [SummitEvent] {
        return self.filter { (event) -> Bool in
            event.start.mt_isWithinSameDay(date)
        }
    }
}

public class GeneralSchedulePresenter: SchedulePresenter {
    
    weak var viewController : IScheduleViewController!
    var interactor : IScheduleInteractor!
    var wireframe : IGeneralScheduleWireframe!
    
    public override func viewLoad() {
        viewLoad(interactor, viewController: viewController)
    }
    
    public override func reloadSchedule() {
        reloadSchedule(interactor, viewController: viewController)
    }
    
    public override func buildScheduleCell(cell: IScheduleTableViewCell, index: Int){
        buildScheduleCell(cell, index: index, interactor: interactor)
    }
    
    public override func getDayEventsCount() -> Int {
        return dayEvents.count
    }
    
    public override func showEventDetail(index: Int) {
        let event = dayEvents[index]
        self.wireframe.showEventDetail(event.id)
    }
    
    public override func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        toggleScheduledStatus(index, cell: cell, interactor: interactor, viewController: viewController)
    }
    
    func loggedIn(notification: NSNotification) {
        loggedIn(notification, viewController: viewController)
    }

    func loggedOut(notification: NSNotification) {
        loggedOut(notification, viewController: viewController)
    }
}
