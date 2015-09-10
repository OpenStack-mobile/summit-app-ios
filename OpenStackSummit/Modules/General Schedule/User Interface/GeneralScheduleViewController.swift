//
//  ScheduleViewController.swift
//  OpenStackSched
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AFHorizontalDayPicker

public protocol IGeneralScheduleViewController {
    var startDate: NSDate! { get set }
    var endDate: NSDate! { get set }
    var dayEvents: [ScheduleItemDTO]! { get set }
    
    func handleError(error: NSError)
}

class GeneralScheduleViewController: RevealViewController, UITableViewDelegate, UITableViewDataSource, AFHorizontalDayPickerDelegate, IGeneralScheduleViewController {

    let cellIdentifier = "GeneralScheduleTableViewCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayPicker: AFHorizontalDayPicker!
    
    var presenter : IGeneralSchedulePresenter!
    var dayEvents : [ScheduleItemDTO]!
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
        
        tableView.delegate = self
        tableView.dataSource = self
        
        dayPicker.delegate = self
        
        presenter.viewLoad()
    }

    
    func reloadSchedule() {
        tableView.reloadData()
    }

    func handleError(error: NSError) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayEvents!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = dayEvents![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GeneralScheduleTableViewCell
        
        cell.eventTitleLabel.text = event.title;
        cell.timeAndPlaceLabel.text = event.date
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        let event = dayEvents![indexPath.row]
        self.presenter.showEventDetail(event.id)
    }
    
    func horizontalDayPicker(horizontalDayPicker: AFHorizontalDayPicker, widthForItemWithDate date: NSDate) -> CGFloat {
        let width: CGFloat = 50
        return width
    }
    
    func horizontalDayPicker(horizontalDayPicker: AFHorizontalDayPicker, didSelectDate date: NSDate) -> Void {
        self.presenter.reloadSchedule()
    }
}
