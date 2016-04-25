//
//  ScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AFHorizontalDayPicker

@objc
public protocol IScheduleViewController: class, IMessageEnabledViewController {
    var startDate: NSDate! { get set }
    var endDate: NSDate! { get set }
    var selectedDate: NSDate! { get set }
    var availableDates: [NSDate]! { get set }
    var title: String! { get set }
    
    func reloadSchedule()
    func showActivityIndicator()
    func hideActivityIndicator()
    func toggleEventList(show: Bool)
    func toggleNoConnectivityMessage(show: Bool)
}

class ScheduleViewController: BaseViewController, AFHorizontalDayPickerDelegate, UITableViewDelegate, UITableViewDataSource, IScheduleViewController {
    
    @IBOutlet weak var scheduleView: ScheduleView!
    
    let cellIdentifier = "scheduleTableViewCell"
    var internalPresenter: ISchedulePresenter!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleView.dayPicker.delegate = self
        
        scheduleView.tableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        scheduleView.tableView.estimatedRowHeight = 188
        scheduleView.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func reloadSchedule() {
        scheduleView.tableView.delegate = self
        scheduleView.tableView.dataSource = self
        scheduleView.tableView.reloadData()
    }
    
    func showActivityIndicator() {}
    func hideActivityIndicator() {}
    
    func toggleEventList(show: Bool) {}
    func toggleNoConnectivityMessage(show: Bool) {}
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker, widthForItemWithDate date: NSDate) -> CGFloat {
        return scheduleView.horizontalDayPicker(picker, widthForItemWithDate: date)
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker!, requestCustomizedCellFromCell cell: AFDayCell!) -> AFDayCell! {
        return scheduleView.horizontalDayPicker(picker, requestCustomizedCellFromCell: cell)
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker, didSelectDate date: NSDate) -> Void {
        internalPresenter.reloadSchedule()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell
        internalPresenter.buildScheduleCell(cell, index: indexPath.row)
        cell.scheduleButton.addTarget(self, action: "toggleScheduledStatus:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        internalPresenter.showEventDetail(indexPath.row)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let eventCount = internalPresenter.getDayEventsCount();
        scheduleView.tableView.hidden = eventCount == 0
        scheduleView.noEventsLabel.hidden = eventCount > 0
        return eventCount
    }
    
    func toggleScheduledStatus(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! UITableViewCell
        let indexPath = scheduleView.tableView.indexPathForCell(cell)
        internalPresenter.toggleScheduledStatus(indexPath!.row, cell: view.superview as! IScheduleTableViewCell)
    }
}
