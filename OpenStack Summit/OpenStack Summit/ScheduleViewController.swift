//
//  ScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import SwiftFoundation
import UIKit
import AFHorizontalDayPicker
import CoreSummit

class ScheduleViewController: UIViewController, MessageEnabledViewController, ShowActivityIndicatorProtocol, AFHorizontalDayPickerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scheduleView: ScheduleView!
    
    // MARK: - Properties
    
    var summitTimeZoneOffset: Int = 0
    
    private(set) var dayEvents = [ScheduleItem]()
    
    var scheduleFilter = ScheduleFilter()
    
    // MARK: - Accessors
    
    var startDate: NSDate! {
        get {
            return scheduleView.dayPicker.startDate
        }
        set {
            scheduleView.dayPicker.startDate = newValue
            scheduleView.dayPicker.firstActiveDate = newValue
        }
    }
    
    var endDate: NSDate! {
        get {
            return scheduleView.dayPicker.endDate
        }
        set {
            scheduleView.dayPicker.endDate = newValue
            scheduleView.dayPicker.lastActiveDate = newValue
        }
    }
    
    var selectedDate: NSDate! {
        get {
            return scheduleView.dayPicker.selectedDate
        }
        set {
            scheduleView.dayPicker.selectDate(newValue, animated: false)
        }
    }
    
    var availableDates: [NSDate]! {
        get {
            return scheduleView.activeDates
        }
        set {
            scheduleView.activeDates = newValue
        }
    }
    
    // MARK: - Loading
    
    deinit {
        
        stopNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBlankBackBarButtonItem()
        
        scheduleView.dayPicker.delegate = self
        
        scheduleView.tableView.registerNib(R.nib.scheduleTableViewCell)
        scheduleView.tableView.delegate = self
        scheduleView.tableView.dataSource = self
        scheduleView.tableView.estimatedRowHeight = 188
        scheduleView.tableView.rowHeight = UITableViewAutomaticDimension
        
        // register for notifications
        registerNotifications()
    }
    
    // MARK: - Actions
    
    @IBAction func toggleScheduledStatus(sender: UIButton) {
        
        let button = sender
        let view = button.superview!
        let cell = view.superview as! UITableViewCell
        //let indexPath = scheduleView.tableView.indexPathForCell(cell)
        
        //self.toggleScheduledStatus(indexPath!.row, cell: view.superview as! ScheduleTableViewCell)
    }
    
    // MARK: - Methods
    
    func toggleEventList(show: Bool) {} // override
    
    func toggleNoConnectivityMessage(show: Bool) {} // override
    
    func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        fatalError("You must override this method")
    }
    
    func scheduledEvents(from startDate: NSDate, to endDate: NSDate) -> [ScheduleItem] {
        
        fatalError("You must override this method")
    }
    
    final func reloadSchedule() {
        
        let offsetLocalTimeZone = NSTimeZone.localTimeZone().secondsFromGMT
        
        let startDate = self.selectedDate.mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
        let endDate = self.selectedDate.mt_endOfCurrentDay().mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
        
        self.dayEvents = self.scheduledEvents(from: startDate, to: endDate)
        
        scheduleView.tableView.delegate = self
        scheduleView.tableView.dataSource = self
        scheduleView.tableView.reloadData()
    }
    
    func loadData() {
        
        if let realmSummit = Store.shared.realm.objects(RealmSummit).first {
            
            let summit = Summit(realmEntity: realmSummit)
            
            self.updateUI(summit)
            
        } else {
            
            Store.shared.summit { (response) in
                
                switch response {
                    
                case let .Error(error):
                    
                    self.showErrorMessage(error as NSError)
                    
                    self.scheduleFilter.hasToRefreshSchedule = true
                    self.toggleNoConnectivityMessage(true)
                    self.toggleEventList(false)
                    
                case let .Value(value):
                    
                    self.updateUI(value)
                }
            }
        }
    }
    
    // MARK: Private Methods
    
    private func updateUI(summit: Summit) {
        
        self.subscribeToPushChannelsUsingContextIfNotDoneAlready()
        
        self.summitTimeZoneOffset = NSTimeZone(name: summit.timeZone)!.secondsFromGMT
        
        self.startDate = summit.start.toFoundation().mt_dateSecondsAfter(self.summitTimeZoneOffset).mt_startOfCurrentDay()
        self.endDate = summit.end.toFoundation().mt_dateSecondsAfter(self.summitTimeZoneOffset).mt_dateDaysAfter(1)
        
        self.availableDates = self.scheduleAvailableDates(from: self.startDate, to: self.endDate)
        
        if self.selectedDate != nil {
            if self.availableDates.count > 0 && !self.availableDates.contains(self.selectedDate!) {
                let today = NSDate()
                var selected = self.availableDates.first
                for availableDate in self.availableDates {
                    if availableDate.mt_isWithinSameDay(today) {
                        selected = availableDate
                        break
                    }
                }
                self.selectedDate = selected
            }
        }
        else {
            if self.availableDates.count > 0 {
                let today = NSDate()
                var selected = self.availableDates.first
                for availableDate in self.availableDates {
                    if availableDate.mt_isWithinSameDay(today) {
                        selected = availableDate
                        break
                    }
                }
                self.selectedDate = selected
            }
            else {
                self.selectedDate = self.startDate
            }
        }
    }
    
    func scheduleAvailableDates(from startDate: NSDate, endDate: NSDate) -> [NSDate] {
        
        let eventTypeSelections = self.scheduleFilter.selections[FilterSectionType.EventType]?.map { $0.id }
        let summitTypeSelections = self.scheduleFilter.selections[FilterSectionType.SummitType]?.map { $0.id }
        let trackSelections = self.scheduleFilter.selections[FilterSectionType.Track]?.map { $0.id }
        let trackGroupSelections = self.scheduleFilter.selections[FilterSectionType.TrackGroup]?.map { $0.id }
        let tagSelections = self.scheduleFilter.selections[FilterSectionType.Tag] as? [String]
        let levelSelections = self.scheduleFilter.selections[FilterSectionType.Level] as? [String]
        
        let events = SummitEvent.filter(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels)
        
        var activeDates: [NSDate] = []
        for event in events {
            let timeZone = NSTimeZone(name: event.summit.timeZone)!
            let startDate = event.start.mt_dateSecondsAfter(timeZone.secondsFromGMT).mt_startOfCurrentDay()
            if !activeDates.contains(startDate) {
                activeDates.append(startDate)
            }
            
        }
        return activeDates
    }
    
    
    final func subscribeToPushChannelsUsingContextIfNotDoneAlready() {
        
        /*
         if pushRegisterInProgress {
         return
         }
         
         pushRegisterInProgress = true
         
         if NSUserDefaults.standardUserDefaults().objectForKey("registeredPushNotificationChannels") == nil {
         self.pushNotificationsManager.subscribeToPushChannelsUsingContext(){ (succeeded: Bool, error: NSError?) in
         if succeeded {
         NSUserDefaults.standardUserDefaults().setObject("true", forKey: "registeredPushNotificationChannels")
         }
         self.pushRegisterInProgress = false
         }
         }*/
    }
    
    private final func isDataLoaded() -> Bool {
        
        return Store.shared.realm.objects(RealmSummit.self).first != nil
    }

    private final func eventExist(id: Identifier) -> Bool {
        
        return RealmSummitEvent.find(id, realm: Store.shared.realm) != nil
    }

    private final func isEventScheduledByLoggedMember(eventId: Int) -> Bool {
        
        /* FIXME: Implement Login
        if !Store.shared.isLoggedInAndConfirmedAttendee() {
            return false;
        } */
        
        guard let loggedInMember = Store.shared.authenticatedMember else {
            return false
        }
        
        return loggedInMember.attendeeRole?.scheduledEvents.filter("id = \(eventId)").count > 0
    }
    
    private final func configure(cell cell: ScheduleTableViewCell, at indexPath: NSIndexPath) {
        
        let index = indexPath.row
        let event = dayEvents[index]
        
        cell.eventTitle = event.name
        cell.eventType = event.eventType
        cell.time = event.time
        cell.location = event.location
        cell.sponsors = event.sponsors
        cell.track = event.track
        cell.scheduled = isEventScheduledByLoggedMember(event.id)
        cell.isScheduledStatusVisible = /* Store.shared.isLoggedInAndConfirmedAttendee() */ true // FIXME Login
        cell.trackGroupColor = event.trackGroupColor != "" ? UIColor(hexaString: event.trackGroupColor) : nil
        
        // configure button
        cell.scheduleButton.addTarget(self, action: #selector(ScheduleViewController.toggleScheduledStatus(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.layoutSubviews()
    }
    
    // MARK: - AFHorizontalDayPickerDelegate
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker, widthForItemWithDate date: NSDate) -> CGFloat {
        
        return scheduleView.horizontalDayPicker(picker, widthForItemWithDate: date)
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker!, requestCustomizedCellFromCell cell: AFDayCell!) -> AFDayCell! {
        
        return scheduleView.horizontalDayPicker(picker, requestCustomizedCellFromCell: cell)
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker, didSelectDate date: NSDate) {
        
        scheduleView.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let eventCount = dayEvents.count
        
        scheduleView.tableView.hidden = eventCount == 0
        scheduleView.noEventsLabel.hidden = eventCount > 0
        
        return eventCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.scheduleTableViewCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //internalPresenter.showEventDetail(indexPath.row)
        
        /*
        let event = dayEvents[index]
        if internalInteractor.eventExist(event.id) {
            internalWireframe.showEventDetail(event.id)
        }
        else {
            internalViewController.showInfoMessage("Info", message: "This event was removed from schedule.")
            reloadSchedule()
            
        }*/
    }
    
    // MARK: - Notifications
    
    private func registerNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(ScheduleViewController.loggedIn(_:)),
            name: Notification.loggedIn.rawValue,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(ScheduleViewController.loggedOut(_:)),
            name: Notification.loggedOut.rawValue,
            object: nil)
    }
    
    private func stopNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Notification.loggedIn.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Notification.loggedOut.rawValue, object: nil)
    }
    
    @objc private func loggedIn(notification: NSNotification) {
        
        self.scheduleView.tableView.reloadData()
    }
    
    @objc private func loggedOut(notification: NSNotification) {
        
        self.scheduleView.tableView.reloadData()
    }
}
