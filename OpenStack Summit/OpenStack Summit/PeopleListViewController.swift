//
//  PeopleListViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

final class PeopleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var presenter: IPeoplePresenter!
    var searchTerm: String!
    let cellIdentifier = "peopleTableViewCell"
    @IBOutlet weak var peopleListView: PeopleListView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        peopleListView.tableView.setContentOffset(CGPointZero, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleListView.tableView.registerNib(UINib(nibName: "PeopleTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    func reloadData() {
        peopleListView.tableView.delegate = self
        peopleListView.tableView.dataSource = self
        peopleListView.tableView.reloadData()
    }
    
    func showActivityIndicator() {
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getPeopleCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PeopleTableViewCell
        presenter.buildScheduleCell(cell, index: indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showPersonProfile(indexPath.row)
    }
}