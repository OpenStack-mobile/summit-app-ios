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
import RealmSwift

class ScheduleViewController: UIViewController, FilteredScheduleViewController, MessageEnabledViewController, ShowActivityIndicatorProtocol, AFHorizontalDayPickerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scheduleView: ScheduleView!
    
    // MARK: - Properties
    
    final private(set) var summitTimeZoneOffset: Int = 0
    
    final private(set) var dayEvents = [ScheduleItem]()
    
    var scheduleFilter = ScheduleFilter()
    
    private var pushRegisterInProgress = false
    
    private var realmNotificationToken: RealmSwift.NotificationToken!
    
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
        
        realmNotificationToken?.stop()
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
        
        // load UI
        loadData()
        
        // realm notifications
        realmNotificationToken = Store.shared.realm.addNotificationBlock { (notification, realm) in
            
            self.reloadSchedule()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func toggleScheduledStatus(sender: UIButton) {
        
        let button = sender
        let view = button.superview!
        let cell = view.superview as! ScheduleTableViewCell
        let indexPath = scheduleView.tableView.indexPathForCell(cell)!
        let event = dayEvents[indexPath.row]
        let scheduled = Store.shared.isEventScheduledByLoggedMember(event: event.id)
        
        // update cell
        cell.scheduled = !scheduled
        
        let completion: ErrorValue<()> -> () = { [weak self] (response) in
            
            guard let controller = self else { return }
            
            switch response {
                
            case let .Error(error):
                
                // restore original value
                cell.scheduled = scheduled
                
                // show error
                controller.showErrorMessage(error as NSError)
                
            case .Value(): break
            }
        }
        
        if scheduled {
            
            Store.shared.removeEventFromSchedule(event: event.id, completion: completion)
            
        } else {
            
            Store.shared.addEventToSchedule(event: event.id, completion: completion)
        }
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
    
    func loadData() {
        
        if let realmSummit = Store.shared.realm.objects(RealmSummit).first {
            
            let summit = Summit(realmEntity: realmSummit)
            
            self.updateUI(summit)
            
        } else {
            
            self.showActivityIndicator()
            
            Store.shared.summit { [weak self] (response) in
                
                guard let controller = self else { return }
                
                controller.hideActivityIndicator()
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                    controller.scheduleFilter.hasToRefreshSchedule = true
                    controller.toggleNoConnectivityMessage(true)
                    controller.toggleEventList(false)
                    
                case let .Value(value):
                    
                    controller.updateUI(value)
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
        
        let today = NSDate()
        
        let shoudHidePastTalks = self.scheduleFilter.shoudHidePastTalks()
        
        self.availableDates = self.scheduleAvailableDates(from: shoudHidePastTalks ? today : self.startDate, to: self.endDate)
        
        if self.selectedDate != nil {
            if self.availableDates.count > 0 {
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
        
        reloadSchedule()
    }
    
    private func reloadSchedule() {
        
        let tableView = self.scheduleView.tableView
        
        let oldSchedule = self.dayEvents
        
        let offsetLocalTimeZone = NSTimeZone.localTimeZone().secondsFromGMT
        
        let startDate = self.selectedDate.mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
        let endDate = self.selectedDate.mt_endOfCurrentDay().mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
        
        let today = NSDate()
        
        let shoudHidePastTalks = self.scheduleFilter.shoudHidePastTalks()

        self.dayEvents = self.scheduledEvents(from: shoudHidePastTalks ? today : startDate, to: endDate)
        
        if oldSchedule.isEmpty {
            
            tableView.reloadData()
            
        } else {
            
            tableView.beginUpdates()
            
            defer { tableView.endUpdates() }
            
            // update new schedule with animation
            
            for (index, event) in self.dayEvents.enumerate() {
                
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                
                // add new item
                guard index < oldSchedule.count else {
                    
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ScheduleTableViewCell {
                        
                        configure(cell: cell, at: indexPath)
                    }
                    
                    continue
                }
                
                let oldEvent = oldSchedule[index]
                
                // delete and insert cell (cell represents different event)
                guard event.id == oldEvent.id else {
                    
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ScheduleTableViewCell {
                        
                        configure(cell: cell, at: indexPath)
                    }
                    
                    continue
                }
                
                // update existing cell
                
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ScheduleTableViewCell {
                    
                    configure(cell: cell, at: indexPath)
                }
            }
            
            // remove old items
            if dayEvents.count < oldSchedule.count {
                
                let deletedIndexPaths = (dayEvents.count ..< oldSchedule.count).map { NSIndexPath(forRow: $0, inSection: 0) }
                
                tableView.deleteRowsAtIndexPaths(deletedIndexPaths, withRowAnimation: .Automatic)
            }
        }
    }
    
    private func subscribeToPushChannelsUsingContextIfNotDoneAlready() {
        
        if pushRegisterInProgress {
            return
        }
        
        pushRegisterInProgress = true
        
        if NSUserDefaults.standardUserDefaults().objectForKey("registeredPushNotificationChannels") == nil {
            
            PushNotificationsManager.subscribeToPushChannelsUsingContext() { (succeeded: Bool, error: NSError?) in
                if succeeded {
                    NSUserDefaults.standardUserDefaults().setObject("true", forKey: "registeredPushNotificationChannels")
                }
                self.pushRegisterInProgress = false
            }
        }
    }
    
    private final func isDataLoaded() -> Bool {
        
        return Store.shared.realm.objects(RealmSummit.self).first != nil
    }

    private final func eventExist(id: Identifier) -> Bool {
        
        return RealmSummitEvent.find(id, realm: Store.shared.realm) != nil
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
        cell.scheduled = Store.shared.isEventScheduledByLoggedMember(event: event.id)
        cell.isScheduledStatusVisible = Store.shared.isLoggedInAndConfirmedAttendee
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
        
        reloadSchedule()
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
        
        let scheduleItem = dayEvents[indexPath.row]
        
        if let _ = RealmSummitEvent.find(scheduleItem.id, realm: Store.shared.realm) {
            
            let eventDetailVC = R.storyboard.event.eventDetailViewController()!
            
            eventDetailVC.event = scheduleItem.id
            
            self.showViewController(eventDetailVC, sender: self)
            
        } else {
            
            showInfoMessage("Info", message: "This event was removed from schedule.")
            self.scheduleView.tableView.reloadData()
        }
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
