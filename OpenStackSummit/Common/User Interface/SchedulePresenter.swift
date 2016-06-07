//
//  SchedulePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import MTDates

public protocol SchedulePresenterProtocol {
    
    func viewLoad()
    func reloadSchedule()
    func getDayEventsCount() -> Int
    func buildScheduleCell(cell: ScheduleTableViewCellProtocol, index: Int)
    func toggleScheduledStatus(index: Int, cell: ScheduleTableViewCellProtocol)
    func showEventDetail(index: Int)
}

public class SchedulePresenter: ScheduleablePresenter, SchedulePresenterProtocol {
    
    // MARK: - Properties
    
    var summitTimeZoneOffset: Int = 0
    var session = Session()
    var dayEvents = [ScheduleItem]()
    var scheduleFilter = ScheduleFilter()
    var internalInteractor: ScheduleInteractorProtocol!
    var internalViewController: ScheduleViewControllerProtocol!
    var internalWireframe: ScheduleWireframe!
    var selectedDate: NSDate?
    
    // MARK: - Methods
    
    public func viewLoad() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.LoggedInNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.LoggedOutNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SchedulePresenter.loggedIn(_:)),
            name: Constants.Notifications.LoggedInNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SchedulePresenter.loggedOut(_:)),
            name: Constants.Notifications.LoggedOutNotification,
            object: nil)

        viewLoad(internalInteractor, viewController: internalViewController)
    }
    
    public func reloadSchedule() {
        reloadSchedule(internalInteractor, viewController: internalViewController)
    }
    
    public func buildScheduleCell(cell: ScheduleTableViewCell, index: Int){
        let event = dayEvents[index]
        cell.eventTitle = event.name
        cell.eventType = event.eventType
        cell.time = event.time
        cell.location = event.location
        cell.sponsors = event.sponsors
        cell.track = event.track
        cell.scheduled = internalInteractor.isEventScheduledByLoggedMember(event.id)
        cell.isScheduledStatusVisible = internalInteractor.isLoggedInAndConfirmedAttendee()
        cell.trackGroupColor = event.trackGroupColor != "" ? UIColor(hexaString: event.trackGroupColor) : nil
    }
    
    public func getDayEventsCount() -> Int {
        return dayEvents.count
    }
    
    public func showEventDetail(index: Int) {
        let event = dayEvents[index]
        if internalInteractor.eventExist(event.id) {
            internalWireframe.showEventDetail(event.id)
        }
        else {
            internalViewController.showInfoMessage("Info", message: "This event was removed from schedule.")
            reloadSchedule()
            
        }
    }
    
    public func toggleScheduledStatus(index: Int, cell: ScheduleTableViewCellProtocol) {
        let event = dayEvents[index]
        toggleScheduledStatusForEvent(event, scheduleableView: cell, interactor: internalInteractor) { error in
            if (error != nil) {
                self.internalViewController.showErrorMessage(error!)
            }
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func loggedIn(notification: NSNotification) {
        internalViewController.reloadSchedule()
    }
    
    @objc private func loggedOut(notification: NSNotification) {
        
        if dayEvents.isEmpty == nil {
            internalViewController.reloadSchedule()
        }
    }
    
    private func viewLoad(interactor: ScheduleInteractorProtocol, viewController: ScheduleViewController) {
        if !interactor.isDataLoaded() {
            internalViewController.showActivityIndicator()
        }
        
        interactor.getActiveSummit() { summit, error in
            dispatch_async(dispatch_get_main_queue(),{
                defer { viewController.hideActivityIndicator() }

                self.internalInteractor.subscribeToPushChannelsUsingContextIfNotDoneAlready()

                if (error != nil) {
                    viewController.showErrorMessage(error!)
                    
                    self.scheduleFilter.hasToRefreshSchedule = true
                    viewController.toggleNoConnectivityMessage(true)
                    viewController.toggleEventList(false)
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
                        let today = NSDate()
                        var selected = viewController.availableDates.first
                        for availableDate in viewController.availableDates {
                            if availableDate.mt_isWithinSameDay(today) {
                                selected = availableDate
                                break
                            }
                        }
                        viewController.selectedDate = selected
                    }
                    else {
                        viewController.selectedDate = self.selectedDate
                    }
                }
                else {
                    if viewController.availableDates.count > 0 {
                        let today = NSDate()
                        var selected = viewController.availableDates.first
                        for availableDate in viewController.availableDates {
                            if availableDate.mt_isWithinSameDay(today) {
                                selected = availableDate
                                break
                            }
                        }
                        viewController.selectedDate = selected
                    }
                    else {
                        viewController.selectedDate = viewController.startDate
                    }
                }
            })
        }
    }
    
    func reloadSchedule(interactor: ScheduleInteractorProtocol, viewController: ScheduleViewController) {
        dispatch_async(dispatch_get_main_queue(),{
            self.selectedDate = viewController.selectedDate
            
            let offsetLocalTimeZone = NSTimeZone.localTimeZone().secondsFromGMT
            
            let startDate = viewController.selectedDate.mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
            let endDate = viewController.selectedDate.mt_endOfCurrentDay().mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
            
            self.dayEvents = self.getScheduledEventsFrom(startDate, to: endDate, withInteractor: interactor)
            
            viewController.reloadSchedule()
        })
    }
    
    func getScheduleAvailableDatesFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: ScheduleInteractorProtocol) -> [NSDate] {
        fatalError("You must override this method")
    }

    func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: ScheduleInteractorProtocol) -> [ScheduleItem] {
        fatalError("You must override this method")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.LoggedInNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.LoggedOutNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
