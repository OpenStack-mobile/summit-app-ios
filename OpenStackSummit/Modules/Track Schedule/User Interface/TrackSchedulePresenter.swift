//
//  TrackSchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackSchedulePresenter {
    func reloadSchedule()
    func showEventDetail(index: Int)
    func viewLoad(trackId: Int)
    func viewLoad()
    func buildScheduleCell(cell: IScheduleTableViewCell, index: Int)
    func getDayEventsCount() -> Int
    func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell)
}

public class TrackSchedulePresenter: SchedulePresenter {
    var trackId = 0
    weak var viewController : IScheduleViewController!
    var interactor : IScheduleInteractor!
    var wireframe : ITrackScheduleWireframe!
    var isLoaded = false
    
    public func viewLoad(trackId: Int) {
        self.trackId = trackId
        viewLoad()
    }
    
    public override func viewLoad() {
        viewLoad(interactor, viewController: viewController)
    }
    
    public override func reloadSchedule() {
        scheduleFilter.selections[FilterSectionTypes.Track] = [Int]()
        scheduleFilter.selections[FilterSectionTypes.Track]!.append(trackId)
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
