//
//  ScheduleViewController.swift
//  OpenStackSched
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

class GeneralScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "scheduleCellIdentifier"
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var presenter : GeneralSchedulePresenter?
    var events : [SummitEvent]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        presenter?.reloadScheduleAsync()
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
        return events!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let eventText = events![indexPath.row].eventDescription
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.text = eventText
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        presenter?.showEventDetail(1)
    }
}
