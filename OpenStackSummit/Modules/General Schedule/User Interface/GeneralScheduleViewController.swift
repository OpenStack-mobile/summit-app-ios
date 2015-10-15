//
//  ScheduleViewController.swift
//  OpenStackSched
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AFHorizontalDayPicker
import SwiftSpinner

class GeneralScheduleViewController: RevealViewController, UITableViewDelegate, UITableViewDataSource, AFHorizontalDayPickerDelegate, IScheduleViewController {

    let cellIdentifier = "GeneralScheduleTableViewCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayPicker: AFHorizontalDayPicker!
    
    var presenter : ISchedulePresenter!
    var startDate: NSDate! {
        get {
            return dayPicker.startDate
        }
        set {
            dayPicker.startDate = newValue
            dayPicker.firstActiveDate = newValue
        }
    }

    var endDate: NSDate! {
        get {
            return dayPicker.endDate
        }
        set {
            dayPicker.endDate = newValue
            dayPicker.lastActiveDate = newValue
        }
    }

    var selectedDate: NSDate! {
        get {
            return dayPicker.selectedDate
        }
        set {
            dayPicker.selectDate(newValue, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayPicker.delegate = self
        presenter.viewLoad()
    }

    
    func reloadSchedule() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    func showErrorMessage(error: NSError) {
        
    }
    
    func showActivityIndicator() {
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GeneralScheduleTableViewCell
        presenter.buildScheduleCell(cell, index: indexPath.row)
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
        
    @IBAction func toggleSchedule(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! GeneralScheduleTableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        presenter.toggleScheduledStatus(indexPath!.row, cell: cell)
    }
    
}
