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
    var title: String! { get set }
    
    func reloadSchedule()
    func showActivityIndicator()
    func hideActivityIndicator()
}

class ScheduleViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, AFHorizontalDayPickerDelegate, IScheduleViewController {
    
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
        scheduleView.tableView.estimatedRowHeight = 142
        scheduleView.tableView.rowHeight = UITableViewAutomaticDimension
        
        scheduleView.dayPicker.delegate = self
        scheduleView.dayPicker.backgroundColor = UIColor(hexaString: "#E5E5E5")
        
        scheduleView.dayPicker.dayNumberActiveColor = UIColor(hexaString: "#4A4A4A")
        scheduleView.dayPicker.dayNumberInactiveColor = UIColor(hexaString: "#4A4A4A")
        scheduleView.dayPicker.dayNumberSelectedColor = UIColor(hexaString: "#FFFFFF")
        
        /*
        scheduleView.dayPicker.dayNumberActiveFont = UIFont.systemFontOfSize(16)
        scheduleView.dayPicker.dayNumberInactiveFont = UIFont.systemFontOfSize(16)
        scheduleView.dayPicker.dayNumberSelectedFont = UIFont.systemFontOfSize(16)*/
        
        scheduleView.dayPicker.dayNameActiveColor = UIColor(hexaString: "#4A4A4A")
        scheduleView.dayPicker.dayNameInactiveColor = UIColor(hexaString: "#4A4A4A")
        scheduleView.dayPicker.dayNameSelectedColor = UIColor(hexaString: "#FFFFFF")
        
        /*
        scheduleView.dayPicker.dayNameActiveFont = UIFont.systemFontOfSize(16)
        scheduleView.dayPicker.dayNameInactiveFont = UIFont.systemFontOfSize(16)
        scheduleView.dayPicker.dayNameSelectedFont = UIFont.systemFontOfSize(16)*/
        
        scheduleView.dayPicker.backgroundActiveColor = UIColor(hexaString: "#E5E5E5")
        scheduleView.dayPicker.backgroundInactiveColor = UIColor(hexaString: "#E5E5E5")
        scheduleView.dayPicker.backgroundSelectedColor = UIColor(hexaString: "#F5A623")
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
        let eventCount = internalPresenter.getDayEventsCount();
        scheduleView.tableView.hidden = eventCount == 0
        scheduleView.noEventsLabel.hidden = eventCount > 0
        return eventCount
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
