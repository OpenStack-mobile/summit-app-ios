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
    
    func reloadSchedule()
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
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleView.tableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        scheduleView.tableView.estimatedRowHeight = 120
        scheduleView.tableView.rowHeight = UITableViewAutomaticDimension
        
        scheduleView.dayPicker.delegate = self
        scheduleView.dayPicker.backgroundColor = UIColorFromRGB(0xE5E5E5)
        
        scheduleView.dayPicker.dayNumberActiveColor = UIColorFromRGB(0x4A4A4A)
        scheduleView.dayPicker.dayNumberInactiveColor = UIColorFromRGB(0x4A4A4A)
        scheduleView.dayPicker.dayNumberSelectedColor = UIColorFromRGB(0xFFFFFF)
        
        /*
        scheduleView.dayPicker.dayNumberActiveFont = UIFont.systemFontOfSize(16)
        scheduleView.dayPicker.dayNumberInactiveFont = UIFont.systemFontOfSize(16)
        scheduleView.dayPicker.dayNumberSelectedFont = UIFont.systemFontOfSize(16)*/
        
        scheduleView.dayPicker.dayNameActiveColor = UIColorFromRGB(0x4A4A4A)
        scheduleView.dayPicker.dayNameInactiveColor = UIColorFromRGB(0x4A4A4A)
        scheduleView.dayPicker.dayNameSelectedColor = UIColorFromRGB(0xFFFFFF)
        
        /*
        scheduleView.dayPicker.dayNameActiveFont = UIFont.systemFontOfSize(16)
        scheduleView.dayPicker.dayNameInactiveFont = UIFont.systemFontOfSize(16)
        scheduleView.dayPicker.dayNameSelectedFont = UIFont.systemFontOfSize(16)*/
        
        scheduleView.dayPicker.backgroundActiveColor = UIColorFromRGB(0xE5E5E5)
        scheduleView.dayPicker.backgroundInactiveColor = UIColorFromRGB(0xE5E5E5)
        scheduleView.dayPicker.backgroundSelectedColor = UIColorFromRGB(0xF5A623)
    }
    
    
    func reloadSchedule() {
        scheduleView.tableView.delegate = self
        scheduleView.tableView.dataSource = self
        scheduleView.tableView.reloadData()
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
        let width: CGFloat = 56
        return width
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell
        internalPresenter.buildScheduleCell(cell, index: indexPath.row)
        cell.scheduleButton.addTarget(self, action: "toggleScheduledStatus:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
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
