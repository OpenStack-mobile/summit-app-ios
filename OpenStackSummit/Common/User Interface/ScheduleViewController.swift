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

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AFHorizontalDayPickerDelegate {
    
    @IBOutlet weak var scheduleView: ScheduleView!
    var presenter: ITrackSchedulePresenter!
    let cellIdentifier = "scheduleTableViewCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayPicker: AFHorizontalDayPicker!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleView.tableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        scheduleView.dayPicker.delegate = self
        presenter.viewLoad()
        self.presenter.reloadSchedule()
    }
    
    
    func reloadSchedule() {
        scheduleView.tableView.delegate = self
        scheduleView.tableView.dataSource = self
        
        scheduleView.tableView.reloadData()
    }
    
    func showErrorMessage(error: NSError) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getDayEventsCount();
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell
        presenter.buildCell(cell, index: indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showEventDetail(indexPath.row)
    }
    
    func horizontalDayPicker(horizontalDayPicker: AFHorizontalDayPicker, widthForItemWithDate date: NSDate) -> CGFloat {
        let width: CGFloat = 50
        return width
    }
    
    func horizontalDayPicker(horizontalDayPicker: AFHorizontalDayPicker, didSelectDate date: NSDate) -> Void {
        self.presenter.reloadSchedule()
    }
}
