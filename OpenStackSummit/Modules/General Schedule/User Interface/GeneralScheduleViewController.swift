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

    let cellIdentifier = "scheduleTableViewCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayPicker: AFHorizontalDayPicker!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var presenter : IGeneralSchedulePresenter!
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
    
    override func viewWillAppear(animated: Bool) {
        dayPicker.delegate = self
        presenter.viewLoad()
        filterButton.target = self
    }
    
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

        tableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        dayPicker.backgroundColor = UIColorFromRGB(0xE5E5E5)
        
        dayPicker.dayNumberActiveColor = UIColorFromRGB(0x4A4A4A)
        dayPicker.dayNumberInactiveColor = UIColorFromRGB(0x4A4A4A)
        dayPicker.dayNumberSelectedColor = UIColorFromRGB(0xFFFFFF)
        
        /*
        dayPicker.dayNumberActiveFont = UIFont.systemFontOfSize(16)
        dayPicker.dayNumberInactiveFont = UIFont.systemFontOfSize(16)
        dayPicker.dayNumberSelectedFont = UIFont.systemFontOfSize(16)*/
        
        dayPicker.dayNameActiveColor = UIColorFromRGB(0x4A4A4A)
        dayPicker.dayNameInactiveColor = UIColorFromRGB(0x4A4A4A)
        dayPicker.dayNameSelectedColor = UIColorFromRGB(0xFFFFFF)
        
        /*
        dayPicker.dayNameActiveFont = UIFont.systemFontOfSize(16)
        dayPicker.dayNameInactiveFont = UIFont.systemFontOfSize(16)
        dayPicker.dayNameSelectedFont = UIFont.systemFontOfSize(16)*/

        dayPicker.backgroundActiveColor = UIColorFromRGB(0xE5E5E5)
        dayPicker.backgroundInactiveColor = UIColorFromRGB(0xE5E5E5)
        dayPicker.backgroundSelectedColor = UIColorFromRGB(0xF5A623)
        /*
        @property (nonatomic, assign) BOOL showSeparatorsBetweenCells;
        @property (nonatomic, assign) BOOL showTopSeparator;
        @property (nonatomic, assign) BOOL showBottomSeparator;
        
        @property (nonatomic, strong) UIColor *separatorActiveColor;
        @property (nonatomic, strong) UIColor *separatorInactiveColor;
        @property (nonatomic, strong) UIColor *separatorSelectedColor;
        
        @property (nonatomic, strong) UIColor *topAndBottomSeparatorsColor;*/

        let border = CALayer()
        border.backgroundColor = UIColorFromRGB(0x9B9B9B).CGColor
        border.frame = CGRectMake(0, dayPicker.frame.size.height - 0.1, dayPicker.frame.size.width, 0.1)
        dayPicker.layer.addSublayer(border)
        
        filterButton.action = Selector("showFilters:")
    }

    @IBAction func showFilters(sender: UIBarButtonItem) {
        presenter.showFilters()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell
        presenter.buildScheduleCell(cell, index: indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showEventDetail(indexPath.row)
    }
    
    func horizontalDayPicker(horizontalDayPicker: AFHorizontalDayPicker, widthForItemWithDate date: NSDate) -> CGFloat {
        let width: CGFloat = 60
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
