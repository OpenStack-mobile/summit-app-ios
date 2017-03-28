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
import CoreData
import EventKit
import JGProgressHUD

class ScheduleViewController: UIViewController, EventViewController, MessageEnabledViewController, ActivityViewController, AFHorizontalDayPickerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    typealias DateFilter = EventManagedObject.DateFilter
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scheduleView: ScheduleView!
    
    // MARK: - Properties
    
    final var eventRequestInProgress = false
    
    final lazy var eventStore: EKEventStore = EKEventStore()
    
    final lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .Dark)
    
    final private(set) var summitTimeZoneOffset: Int = 0
    
    final private(set) var dayEvents = [ScheduleItem]()
    
    final private(set) var nowSelected = false
            
    private var filterObserver: Int?
    
    private var didSelectDate = false
    
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
        
        if let observer = filterObserver { FilterManager.shared.filter.remove(observer) }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setBlankBackBarButtonItem()
        
        scheduleView.dayPicker.delegate = self
        scheduleView.nowButton.addTarget(self, action: #selector(nowTapped), forControlEvents: .TouchUpInside)
        
        scheduleView.tableView.registerNib(R.nib.scheduleTableViewCell)
        scheduleView.tableView.delegate = self
        scheduleView.tableView.dataSource = self
        scheduleView.tableView.estimatedRowHeight = 188
        scheduleView.tableView.rowHeight = UITableViewAutomaticDimension
        
        // register for notifications
        registerNotifications()
        
        // load UI
        loadData()
        
        // filter notifications
        filterObserver = FilterManager.shared.filter.observe { _ in self.filterUpdated() }
    }
    
    // MARK: - Actions
    
    @IBAction func nowTapped(sender: UIButton) {
        
        let now = NSDate()
        
        guard let today = self.availableDates.firstMatching({ $0.mt_isWithinSameDay(now) })
            else { return }
        
        self.selectedDate = today
        
        self.didSelectDate = true
        
        self.nowSelected = true
        
        self.loadData()
    }
    
    @IBAction func showEventContextMenu(sender: UIButton) {
        
        let tableView = scheduleView.tableView
        let buttonOrigin = sender.convertPoint(.zero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(buttonOrigin)!
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as! ScheduleTableViewCell
        let scheduleItem = dayEvents[indexPath.row]
        
        guard let eventManagedObject = try! EventManagedObject.find(scheduleItem.identifier, context: Store.shared.managedObjectContext)
            else { fatalError("Invalid event \(scheduleItem.identifier)") }
        
        let eventDetail = EventDetail(managedObject: eventManagedObject)
        
        let contextMenu = self.contextMenu(for: eventDetail)
        
        self.show(contextMenu: contextMenu, sender: .view(sender))
    }
    
    // MARK: - Methods
    
    func toggleEventList(show: Bool) {} // override
    
    func toggleNoConnectivityMessage(show: Bool) {} // override
    
    func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        fatalError("You must override this method")
    }
    
    func scheduledEvents(filter: DateFilter) -> [ScheduleItem] {
        
        fatalError("You must override this method")
    }
    
    func loadData() {
        
        if let summitManagedObject = self.currentSummit {
            
            let summit = Summit(managedObject: summitManagedObject)
            
            self.updateUI(summit)
            
        } else {
            
            self.showActivityIndicator()
            
            Store.shared.summit(SummitManager.shared.summit.value) { [weak self] (response) in
                
                guard let controller = self else { return }
                
                controller.dismissActivityIndicator()
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
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
        
        let scheduleFilter = FilterManager.shared.filter.value
                
        let timeZone = NSTimeZone(name: summit.timeZone)!
        
        NSDate.mt_setTimeZone(timeZone)
        
        self.summitTimeZoneOffset = timeZone.secondsFromGMT
        
        self.startDate = summit.start.toFoundation().mt_dateSecondsAfter(self.summitTimeZoneOffset).mt_startOfCurrentDay()
        self.endDate = summit.end.toFoundation().mt_dateSecondsAfter(self.summitTimeZoneOffset).mt_dateDaysAfter(1)
        
        let today = NSDate()
        
        let shoudHidePastTalks = scheduleFilter.activeFilters.contains(.activeTalks)
        
        self.availableDates = self.scheduleAvailableDates(from: shoudHidePastTalks ? today : self.startDate, to: self.endDate)
        
        let summitActive = today.mt_isBetweenDate(self.startDate, andDate: self.endDate)
        
        self.scheduleView.nowButtonEnabled = summitActive
        
        // default start day when summit is inactive
        
        let oldSelectedDate = self.selectedDate
        
        let oldNowSelected = self.nowSelected
        
        if let defaultStart = summit.defaultStart?.toFoundation(),
            let defaultDay = self.availableDates.firstMatching({ $0.mt_isWithinSameDay(defaultStart) })
            where summitActive == false && self.didSelectDate == false {
            
            self.selectedDate = defaultDay
            
        } else if self.didSelectDate == false || self.availableDates.contains(self.selectedDate) == false {
            
            self.selectedDate = self.availableDates.firstMatching({ $0.mt_isWithinSameDay(today) }) ?? self.availableDates.first
            
        } else {
            
            self.selectedDate = oldSelectedDate
        }
        
        self.nowSelected = oldNowSelected
        
        reloadSchedule()
    }
    
    private func reloadSchedule() {
        
        guard self.scheduleView.dayPicker.selectedDate != nil else { return }
        
        let scheduleFilter = FilterManager.shared.filter.value
        
        let tableView = self.scheduleView.tableView
        
        let oldSchedule = self.dayEvents
        
        // fetch new events
        
        if nowSelected {
            
            self.dayEvents = self.scheduledEvents(.now)
            
        } else {
            
            let offsetLocalTimeZone = NSTimeZone.localTimeZone().secondsFromGMT
            
            let startDate = self.selectedDate.mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
            let endDate = self.selectedDate.mt_endOfCurrentDay().mt_dateSecondsAfter(offsetLocalTimeZone - self.summitTimeZoneOffset)
            
            let today = NSDate()
            
            let shoudHidePastTalks = scheduleFilter.activeFilters.contains(.activeTalks)
            
            let dailyScheduleStartDate: NSDate
            
            if shoudHidePastTalks {
                
                dailyScheduleStartDate = startDate.mt_isAfter(today) ? startDate : today
                
            } else {
                
                dailyScheduleStartDate = startDate
            }
            
            self.dayEvents = self.scheduledEvents(.interval(start: Date(foundation: dailyScheduleStartDate), end: Date(foundation: endDate)))
        }
        
        // reload table view
        
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
                guard event.identifier == oldEvent.identifier else {
                    
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
    
    @inline(__always)
    private func eventExists(id: Identifier) -> Bool {
        
        return try! EventManagedObject.find(id, context: Store.shared.managedObjectContext) != nil
    }
    
    private func configure(cell cell: ScheduleTableViewCell, at indexPath: NSIndexPath) {
        
        let index = indexPath.row
        let event = dayEvents[index]
        
        // set text
        cell.nameLabel.text = event.name
        cell.dateTimeLabel.text = event.dateTime
        cell.trackLabel.text = event.track
        cell.trackLabel.hidden = event.track.isEmpty
        cell.trackLabel.textColor = UIColor(hexString: event.trackGroupColor) ?? UIColor(hexString: "#9B9B9B")
        
        // set image
        let isScheduled = Store.shared.isEventScheduledByLoggedMember(event: event.identifier)
        let isFavorite = Store.shared.authenticatedMember?.isFavorite(event: event.identifier) ?? false
        
        if isScheduled {
            
            cell.statusImageView.hidden = false
            cell.statusImageView.image = R.image.contextMenuScheduleAdd()!
            
        } else if isFavorite {
            
            cell.statusImageView.hidden = false
            cell.statusImageView.image = R.image.contextMenuWatchListAdd()!
            
        } else {
            
            cell.statusImageView.hidden = true
            cell.statusImageView.image = nil
            
        }
        
        // configure button
        cell.contextMenuButton.addTarget(self, action: #selector(showEventContextMenu), forControlEvents: .TouchUpInside)
    }
    
    private func filterUpdated() {
        
        // force view load
        let _ = self.view
        
        self.loadData()
    }
    
    // MARK: - AFHorizontalDayPickerDelegate
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker, widthForItemWithDate date: NSDate) -> CGFloat {
        
        return scheduleView.horizontalDayPicker(picker, widthForItemWithDate: date)
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker!, requestCustomizedCellFromCell cell: AFDayCell!) -> AFDayCell! {
        
        return scheduleView.horizontalDayPicker(picker, requestCustomizedCellFromCell: cell)
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker, didSelectDate date: NSDate) {
        
        self.didSelectDate = true
        
        self.nowSelected = false
        
        reloadSchedule()
        
        if dayEvents.isEmpty == false {
            
            self.scheduleView.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
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
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let scheduleItem = dayEvents[indexPath.row]
        
        if let _ = try! EventManagedObject.find(scheduleItem.identifier, context: Store.shared.managedObjectContext) {
            
            let eventDetailVC = R.storyboard.event.eventDetailViewController()!
            
            eventDetailVC.event = scheduleItem.identifier
            
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
            selector: #selector(loggedIn),
            name: Store.Notification.LoggedIn.rawValue,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(loggedOut),
            name: Store.Notification.LoggedOut.rawValue,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: NSManagedObjectContextObjectsDidChangeNotification,
            object: Store.shared.managedObjectContext)
    }
    
    private func stopNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Store.Notification.LoggedIn.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Store.Notification.LoggedOut.rawValue, object: nil)
    }
    
    @objc private func loggedIn(notification: NSNotification) {
        
        self.scheduleView.tableView.reloadData()
    }
    
    @objc private func loggedOut(notification: NSNotification) {
        
        self.scheduleView.tableView.reloadData()
    }
    
    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        
        self.reloadSchedule()
    }
}
