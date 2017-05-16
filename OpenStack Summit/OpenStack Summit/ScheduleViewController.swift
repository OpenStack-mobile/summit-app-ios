//
//  ScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import AFHorizontalDayPicker
import CoreSummit
import CoreData
import EventKit
import JGProgressHUD

class ScheduleViewController: UIViewController, EventViewController, MessageEnabledViewController, ActivityViewController, AFHorizontalDayPickerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    typealias DateFilter = EventManagedObject.DateFilter
    
    // MARK: - IBOutlet
    
    @IBOutlet private(set) weak var scheduleView: ScheduleView!
    
    // MARK: - Properties
    
    final var eventRequestInProgress = false
    
    final lazy var eventStore: EKEventStore = EKEventStore()
    
    final lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    final private(set) var summitTimeZoneOffset: Int = 0
    
    final private(set) var dayEvents = [ScheduleItem]()
    
    final private(set) var nowSelected = false
            
    private var filterObserver: Int?
    
    private var didSelectDate = false
    
    // MARK: - Accessors
    
    var startDate: Date! {
        get {
            return scheduleView.dayPicker.startDate
        }
        set {
            scheduleView.dayPicker.startDate = newValue
            scheduleView.dayPicker.firstActiveDate = newValue
        }
    }
    
    var endDate: Date! {
        get {
            return scheduleView.dayPicker.endDate
        }
        set {
            scheduleView.dayPicker.endDate = newValue
            scheduleView.dayPicker.lastActiveDate = newValue
        }
    }
    
    var selectedDate: Date! {
        get {
            return scheduleView.dayPicker.selectedDate
        }
        set {
            scheduleView.dayPicker.select(newValue, animated: false)
        }
    }
    
    var availableDates: [Date]! {
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
        scheduleView.nowButton.addTarget(self, action: #selector(nowTapped), for: .touchUpInside)
        
        scheduleView.tableView.register(R.nib.scheduleTableViewCell)
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
    
    @IBAction func nowTapped(_ sender: AnyObject? = nil) {
        
        let now = Date()
        
        guard let today = self.availableDates.first(where: { ($0 as NSDate).mt_is(withinSameDay: now) })
            else { return }
        
        (self.scheduleView.dayPicker.value(forKey: "daysCollectionView") as! UICollectionView).reloadData()
        
        self.nowSelected = true
        
        let oldSelectedDate = self.selectedDate
        
        if oldSelectedDate != today {
            
            reloadSchedule()
        }
                
        self.selectedDate = today
        
        self.nowSelected = false
        
        // only show alert when now button is tapped
        if nowEventIndex() == nil && sender != nil {
            
            showInfoMessage("", message: "All presentations are finished for today."); return
        }
    }
    
    @IBAction func showEventContextMenu(_ sender: UIButton) {
        
        let tableView = scheduleView.tableView!
        let buttonOrigin = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: buttonOrigin)!
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as! ScheduleTableViewCell
        let scheduleItem = dayEvents[indexPath.row]
        
        guard let eventManagedObject = try! EventManagedObject.find(scheduleItem.identifier, context: Store.shared.managedObjectContext)
            else { fatalError("Invalid event \(scheduleItem.identifier)") }
        
        let eventDetail = EventDetail(managedObject: eventManagedObject)
        
        let contextMenu = self.contextMenu(for: eventDetail)
        
        self.show(contextMenu: contextMenu, sender: .view(sender))
    }
    
    // MARK: - Methods
    
    func toggleEventList(_ show: Bool) {} // override
    
    func toggleNoConnectivityMessage(_ show: Bool) {} // override
    
    func scheduleAvailableDates(from startDate: Date, to endDate: Date) -> [Date] {
        
        fatalError("You must override this method")
    }
    
    func scheduledEvents(_ filter: DateFilter) -> [ScheduleItem] {
        
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
                    
                case let .error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                    controller.toggleNoConnectivityMessage(true)
                    controller.toggleEventList(false)
                    
                case let .value(value):
                    
                    controller.updateUI(value)
                }
            }
        }
    }
    
    // MARK: Private Methods
    
    private func updateUI(_ summit: Summit) {
        
        let scheduleFilter = FilterManager.shared.filter.value
                
        let timeZone = TimeZone(identifier: summit.timeZone)!
        
        NSDate.mt_setTimeZone(timeZone)
        
        self.summitTimeZoneOffset = timeZone.secondsFromGMT()
        
        self.startDate = ((summit.start as NSDate).mt_dateSeconds(after: self.summitTimeZoneOffset) as NSDate).mt_startOfCurrentDay()
        self.endDate = ((summit.end as NSDate).mt_dateSeconds(after: self.summitTimeZoneOffset) as NSDate).mt_dateDays(after: 1)
        
        let today = Date()
        
        let shoudHidePastTalks = scheduleFilter.activeFilters.contains(.activeTalks)
        
        self.availableDates = self.scheduleAvailableDates(from: shoudHidePastTalks ? today : self.startDate, to: self.endDate)
        
        let summitActive = (today as NSDate).mt_isBetweenDate(self.startDate, andDate: self.endDate)
        
        self.scheduleView.nowButtonEnabled = summitActive
        
        // default start day when summit is inactive
        
        let oldSelectedDate = self.selectedDate
        
        if  let defaultStart = summit.defaultStart,
            let defaultDay = self.availableDates.first(where: { ($0 as NSDate).mt_is(withinSameDay: defaultStart) }),
            summitActive == false && self.didSelectDate == false {
            
            self.selectedDate = defaultDay
            
        } else if self.didSelectDate == false || self.availableDates.contains(self.selectedDate) == false {
            
            self.selectedDate = self.availableDates.first(where: { ($0 as NSDate).mt_is(withinSameDay: today) }) ?? self.availableDates.first
            
        } else {
            
            self.selectedDate = oldSelectedDate
        }
        
        reloadSchedule()
    }
    
    private func reloadSchedule() {
        
        guard self.scheduleView.dayPicker.selectedDate != nil else { return }
        
        let scheduleFilter = FilterManager.shared.filter.value
        
        let tableView = self.scheduleView.tableView
        
        let oldSchedule = self.dayEvents
        
        // fetch new events
        
        let offsetLocalTimeZone = Foundation.NSTimeZone.local.secondsFromGMT()
        
        let startDate = (self.selectedDate! as NSDate).mt_dateSeconds(after: offsetLocalTimeZone - self.summitTimeZoneOffset)!
        let endDate = ((self.selectedDate! as NSDate).mt_endOfCurrentDay() as NSDate).mt_dateSeconds(after: offsetLocalTimeZone - self.summitTimeZoneOffset)!
        
        let today = Date()
        
        let shoudHidePastTalks = scheduleFilter.activeFilters.contains(.activeTalks)
        
        let dailyScheduleStartDate: Date
        
        if shoudHidePastTalks {
            
            dailyScheduleStartDate = (startDate as NSDate).mt_is(after: today) ? startDate : today
            
        } else {
            
            dailyScheduleStartDate = startDate
        }
        
        self.dayEvents = self.scheduledEvents(.interval(start: dailyScheduleStartDate, end: endDate))
        
        // reload table view
        
        if oldSchedule.isEmpty {
            
            tableView?.reloadData()
            
            OperationQueue.main.addOperation {
                
                // jump to NOW
                if self.scheduleView.nowButtonEnabled {
                    
                    self.nowTapped()
                }
            }
            
        } else {
            
            tableView?.beginUpdates()
            
            defer { tableView?.endUpdates() }
            
            // update new schedule with animation
            
            for (index, event) in self.dayEvents.enumerated() {
                
                let indexPath = IndexPath(row: index, section: 0)
                
                // add new item
                guard index < oldSchedule.count else {
                    
                    tableView?.insertRows(at: [indexPath], with: .automatic)
                    
                    if let cell = tableView?.cellForRow(at: indexPath) as? ScheduleTableViewCell {
                        
                        configure(cell: cell, at: indexPath)
                    }
                    
                    continue
                }
                
                let oldEvent = oldSchedule[index]
                
                // delete and insert cell (cell represents different event)
                guard event.identifier == oldEvent.identifier else {
                    
                    tableView?.deleteRows(at: [indexPath], with: .automatic)
                    
                    tableView?.insertRows(at: [indexPath], with: .automatic)
                    
                    if let cell = tableView?.cellForRow(at: indexPath) as? ScheduleTableViewCell {
                        
                        configure(cell: cell, at: indexPath)
                    }
                    
                    continue
                }
                
                // update existing cell
                
                if let cell = tableView?.cellForRow(at: indexPath) as? ScheduleTableViewCell {
                    
                    configure(cell: cell, at: indexPath)
                }
            }
            
            // remove old items
            if dayEvents.count < oldSchedule.count {
                
                let deletedIndexPaths = (dayEvents.count ..< oldSchedule.count).map { IndexPath(row: $0, section: 0) }
                
                tableView?.deleteRows(at: deletedIndexPaths, with: .automatic)
            }
        }
    }
    
    private func configure(cell: ScheduleTableViewCell, at indexPath: IndexPath) {
        
        let index = indexPath.row
        let event = dayEvents[index]
        
        // set text
        cell.nameLabel.text = event.name
        cell.dateTimeLabel.text = event.location.isEmpty ? event.time : event.time + " / " + event.location
        cell.trackLabel.text = event.track
        cell.trackLabel.isHidden = event.track.isEmpty
        cell.trackLabel.textColor = UIColor(hexString: event.trackGroupColor) ?? UIColor(hexString: "#9B9B9B")
        
        // set image
        let isScheduled = Store.shared.isEventScheduledByLoggedMember(event: event.identifier)
        let isFavorite = Store.shared.authenticatedMember?.isFavorite(event: event.identifier) ?? false
        
        if isScheduled {
            
            cell.statusImageView.isHidden = false
            cell.statusImageView.image = #imageLiteral(resourceName: "ContextMenuScheduleAdd")
            
        } else if isFavorite {
            
            cell.statusImageView.isHidden = false
            cell.statusImageView.image = #imageLiteral(resourceName: "ContextMenuWatchListAdd")
            
        } else {
            
            cell.statusImageView.isHidden = true
            cell.statusImageView.image = nil
            
        }
        
        // configure button
        cell.contextMenuButton.addTarget(self, action: #selector(showEventContextMenu), for: .touchUpInside)
    }
    
    private func filterUpdated() {
        
        // force view load
        let _ = self.view
        
        self.loadData()
    }
    
    @inline(__always)
    private func nowEventIndex() -> Int? {
        
        let now = Date()
        
        return self.dayEvents.index(where: { $0.end >= now && $0.track != "General" })
    }
    
    // MARK: - AFHorizontalDayPickerDelegate
    
    func horizontalDayPicker(_ picker: AFHorizontalDayPicker, widthForItemWith date: Date) -> CGFloat {
        
        return scheduleView.horizontalDayPicker(picker, widthForItemWithDate: date)
    }
    
    func horizontalDayPicker(_ picker: AFHorizontalDayPicker!, requestCustomizedCellFrom cell: AFDayCell!) -> AFDayCell! {
        
        return scheduleView.horizontalDayPicker(picker, requestCustomizedCellFromCell: cell)
    }
    
    func horizontalDayPicker(_ picker: AFHorizontalDayPicker, didSelect date: Date) {
        
        self.didSelectDate = true
        
        reloadSchedule()
        
        if dayEvents.isEmpty == false {
            
            let indexPath: IndexPath
            
            if nowSelected {
                
                let currentEventIndex = nowEventIndex() ?? 0
                
                indexPath = IndexPath(row: currentEventIndex, section: 0)
                
            } else {
                
                // scroll to top
                indexPath = IndexPath(row: 0, section: 0)
            }
            
            self.scheduleView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let eventCount = dayEvents.count
        
        scheduleView.tableView.isHidden = eventCount == 0
        scheduleView.noEventsLabel.isHidden = eventCount > 0
        
        return eventCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.scheduleTableViewCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let scheduleItem = dayEvents[indexPath.row]
        
        if let _ = try! EventManagedObject.find(scheduleItem.identifier, context: Store.shared.managedObjectContext) {
            
            let eventDetailVC = R.storyboard.event.eventDetailViewController()!
            
            eventDetailVC.event = scheduleItem.identifier
            
            self.show(eventDetailVC, sender: self)
            
        } else {
            
            showInfoMessage("Info", message: "This event was removed from schedule.")
            self.scheduleView.tableView.reloadData()
        }
    }
    
    // MARK: - Notifications
    
    private func registerNotifications() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loggedIn),
            name: Store.Notification.loggedIn,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loggedOut),
            name: Store.Notification.loggedOut,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: Notification.Name.NSManagedObjectContextObjectsDidChange,
            object: Store.shared.managedObjectContext)
    }
    
    private func stopNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: Store.Notification.loggedIn, object: nil)
        NotificationCenter.default.removeObserver(self, name: Store.Notification.loggedOut, object: nil)
    }
    
    @objc private func loggedIn(_ notification: Foundation.Notification) {
        
        self.scheduleView.tableView.reloadData()
    }
    
    @objc private func loggedOut(_ notification: Foundation.Notification) {
        
        self.scheduleView.tableView.reloadData()
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Foundation.Notification) {
        
        self.reloadSchedule()
    }
}
