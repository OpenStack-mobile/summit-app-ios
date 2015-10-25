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
public protocol IScheduleViewController: class {
    var startDate: NSDate! { get set }
    var endDate: NSDate! { get set }
    var selectedDate: NSDate! { get set }
    
    func reloadSchedule()
    func showErrorMessage(error: NSError)
    func showActivityIndicator()
    func hideActivityIndicator()
}

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AFHorizontalDayPickerDelegate, IScheduleViewController {
    
    @IBOutlet weak var scheduleView: ScheduleView!
    
    let cellIdentifier = "scheduleTableViewCell"
    
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
    
    var internalPresenter: ISchedulePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleView.tableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        scheduleView.dayPicker.delegate = self
    }
    
    
    func reloadSchedule() {
        self.scheduleView.tableView.delegate = self
        self.scheduleView.tableView.dataSource = self            
        self.scheduleView.tableView.reloadData()
    }
    
    func showErrorMessage(error: NSError) {
        
        
    }
    
    func showActivityIndicator() {}
    func hideActivityIndicator() {}

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func horizontalDayPicker(horizontalDayPicker: AFHorizontalDayPicker, widthForItemWithDate date: NSDate) -> CGFloat {
        let width: CGFloat = 50
        return width
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell
        internalPresenter.buildScheduleCell(cell, index: indexPath.row)
        cell.scheduleButton.addTarget(self, action: "toggleScheduledStatus:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        internalPresenter.showEventDetail(indexPath.row)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return internalPresenter.getDayEventsCount();
    }
    
    func horizontalDayPicker(horizontalDayPicker: AFHorizontalDayPicker, didSelectDate date: NSDate) -> Void {
        internalPresenter.reloadSchedule()
    }
    
    func toggleScheduledStatus(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! UITableViewCell
        let indexPath = scheduleView.tableView.indexPathForCell(cell)
        
        internalPresenter.toggleScheduledStatus(indexPath!.row, cell: view.superview as! IScheduleTableViewCell)
    }
}
