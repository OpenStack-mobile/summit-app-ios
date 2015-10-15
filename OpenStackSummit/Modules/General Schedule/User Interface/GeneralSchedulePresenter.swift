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
    var generalScheduleWireframe : IGeneralScheduleWireframe!
    
    public override func viewLoad() {
        viewLoad(interactor, viewController: viewController)
    }
    
    public override func reloadSchedule() {
        reloadSchedule(interactor, viewController: viewController)
    }
    
    public override func buildCell(cell: IScheduleTableViewCell, index: Int){
        buildCell(cell, index: index, interactor: interactor)
    }
    
    public override func getDayEventsCount() -> Int {
        return dayEvents.count
    }
    
    public override func showEventDetail(index: Int) {
        let event = dayEvents[index]
        self.generalScheduleWireframe.showEventDetail(event.id)
    }
    
    public override func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        toggleScheduledStatus(index, cell: cell, interactor: interactor, viewController: viewController)
    }
    
    func loggedIn(notification: NSNotification) {
        viewController.reloadSchedule()
    }

    func loggedOut(notification: NSNotification) {
        viewController.reloadSchedule()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
