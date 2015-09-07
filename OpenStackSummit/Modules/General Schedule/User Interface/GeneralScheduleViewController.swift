//
//  ScheduleViewController.swift
//  OpenStackSched
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AFHorizontalDayPicker

class GeneralScheduleViewController: RevealViewController, UITableViewDelegate, UITableViewDataSource, AFHorizontalDayPickerDelegate {

    let cellIdentifier = "GeneralScheduleTableViewCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayPicker: AFHorizontalDayPicker!
    
    var presenter : IGeneralSchedulePresenter!
    var dayEvents : [SummitEvent]?
    var events : [SummitEvent]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Schedule"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        dayPicker.delegate = self
        
        presenter.reloadScheduleAsync()
    }
    
    func reloadSchedule() {
        tableView.reloadData()
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
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.timeStyle = .ShortStyle
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GeneralScheduleTableViewCell
        
        cell.eventTitleLabel.text = event.eventDescription;
        cell.timeAndPlaceLabel.text = formatter.stringFromDate(event.start) + " - " + formatter.stringFromDate(event.end)
        
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
        self.presenter.reloadSchedule(byDate: date)
    }

}
