//
//  SchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISchedulePresenter {
    func viewLoad()
    func reloadSchedule()
    func getDayEventsCount() -> Int
    func buildScheduleCell(cell: IScheduleTableViewCell, index: Int)
    func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell)
    func showEventDetail(index: Int)
}

public class SchedulePresenter: ScheduleablePresenter, ISchedulePresenter {
    var summitTimeZoneOffset: Int!
    var session: ISession!
    var dayEvents: [ScheduleItemDTO]!
    var scheduleFilter: ScheduleFilter!
    var internalInteractor: IScheduleInteractor!
    var internalViewController: IScheduleViewController!
    var internalWireframe: IScheduleWireframe!
    var selectedDate: NSDate?
    
    public override init() {
        super.init()
    }
    
    public func viewLoad() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.LoggedInNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.LoggedOutNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "loggedIn:",
            name: Constants.Notifications.LoggedInNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "loggedOut:",
            name: Constants.Notifications.LoggedOutNotification,
            object: nil)

        viewLoad(internalInteractor, viewController: internalViewController)
    }
    
    public func reloadSchedule() {
        reloadSchedule(internalInteractor, viewController: internalViewController)
    }
    
    public func buildScheduleCell(cell: IScheduleTableViewCell, index: Int){
        let event = dayEvents[index]
        cell.eventTitle = event.name
        cell.eventType = event.eventType
        cell.time = event.time
        cell.location = event.location
        cell.sponsors = event.sponsors
        cell.track = event.track
        cell.scheduled = internalInteractor.isEventScheduledByLoggedMember(event.id)
        cell.isScheduledStatusVisible = internalInteractor.isMemberLoggedIn()
        cell.trackGroupColor = event.trackGroupColor != "" ? UIColor(hexaString: event.trackGroupColor) : nil
    }
    
    public func getDayEventsCount() -> Int {
        return dayEvents.count
    }
    
    public func showEventDetail(index: Int) {
        let event = dayEvents[index]
        internalWireframe.showEventDetail(event.id)
    }
    
    public func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        let event = dayEvents[index]
        toggleScheduledStatusForEvent(event, scheduleableView: cell, interactor: internalInteractor) { error in
            if (error != nil) {
                self.internalViewController.showErrorMessage(error!)
            }
        }
    }
    
    func loggedIn(notification: NSNotification) {
        internalViewController.reloadSchedule()
    }
    
    func loggedOut(notification: NSNotification) {
        internalViewController.reloadSchedule()
    }
    
    func viewLoad(interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        internalViewController.showActivityIndicator()
        
        interactor.getActiveSummit() { summit, error in
            dispatch_async(dispatch_get_main_queue(),{
                defer { viewController.hideActivityIndicator() }

                self.internalInteractor.subscribeToPushChannelsUsingContextIfNotDoneAlready()

                if (error != nil) {
                    viewController.showErrorMessage(error!)
                    return
                }
                
                self.summitTimeZoneOffset = NSTimeZone(name: summit!.timeZone)!.secondsFromGMT
                
                viewController.startDate = summit!.startDate.mt_dateSecondsAfter(self.summitTimeZoneOffset).mt_startOfCurrentDay()
                viewController.endDate = summit!.endDate.mt_dateSecondsAfter(self.summitTimeZoneOffset).mt_dateDaysAfter(1)
                viewController.availableDates = self.getScheduleAvailableDatesFrom(
                    viewController.startDate,
                    to: viewController.endDate,
                    withInteractor: interactor
                )
                
                if self.selectedDate != nil {
                    if viewController.availableDates.count > 0 && !viewController.availableDates.contains(self.selectedDate!) {
                        viewController.selectedDate = viewController.availableDates.first
                    }
                    else {
                        viewController.selectedDate = self.selectedDate
                    }
                }
                else {
                    if viewController.availableDates.count > 0 {
                        viewController.selectedDate = viewController.availableDates.first
                    }
                    else {
                        viewController.selectedDate = viewController.startDate
                    }
                }
            })
        }
    }
    
    func reloadSchedule(interactor: IScheduleInteractor, viewController: IScheduleViewController) {
        dispatch_async(dispatch_get_main_queue(),{
            self.selectedDate = viewController.selectedDate
            
            let offsetLocalTimeZone = NSTimeZone.localTimeZone().secondsFromGMT
            
            let startDate = viewController.selectedDate.mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
            let endDate = viewController.selectedDate.mt_endOfCurrentDay().mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
            
            self.dayEvents = self.getScheduledEventsFrom(startDate, to: endDate, withInteractor: interactor)
            
            viewController.reloadSchedule()
        })
    }
    
    func getScheduleAvailableDatesFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [NSDate] {
        fatalError("You must override this method")
    }

    func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [ScheduleItemDTO] {
        fatalError("You must override this method")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.LoggedInNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.LoggedOutNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
