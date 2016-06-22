//
//  ScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

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
        
    }
    
    // MARK: - Actions
    
    @IBAction func toggleScheduledStatus(sender: UIButton) {
        
        let button = sender
        let view = button.superview!
        let cell = view.superview as! UITableViewCell
        let indexPath = scheduleView.tableView.indexPathForCell(cell)
        
        self.toggleScheduledStatus(indexPath!.row, cell: view.superview as! ScheduleTableViewCell)
    }
    
    func reloadSchedule() {
        
        scheduleView.tableView.delegate = self
        scheduleView.tableView.dataSource = self
        scheduleView.tableView.reloadData()
    }
    
    func toggleEventList(show: Bool) {}
    
    func toggleNoConnectivityMessage(show: Bool) {}
    
    // MARK: - AFHorizontalDayPickerDelegate
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker, widthForItemWithDate date: NSDate) -> CGFloat {
        
        return scheduleView.horizontalDayPicker(picker, widthForItemWithDate: date)
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker!, requestCustomizedCellFromCell cell: AFDayCell!) -> AFDayCell! {
        
        return scheduleView.horizontalDayPicker(picker, requestCustomizedCellFromCell: cell)
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker, didSelectDate date: NSDate) {
        
        internalPresenter.reloadSchedule()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let eventCount = internalPresenter.getDayEventsCount();
        scheduleView.tableView.hidden = eventCount == 0
        scheduleView.noEventsLabel.hidden = eventCount > 0
        return eventCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.scheduleTableViewCell)!
        
        internalPresenter.buildScheduleCell(cell, index: indexPath.row)
        
        cell.scheduleButton.addTarget(self, action: #selector(ScheduleViewController.toggleScheduledStatus(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.layoutSubviews()
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        internalPresenter.showEventDetail(indexPath.row)
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
        
        
    }
    
    @objc private func loggedOut(notification: NSNotification) {
        
        
    }
}
