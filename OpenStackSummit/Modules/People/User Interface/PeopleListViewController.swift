//
//  PeopleListViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner

@objc
public protocol IPeopleListViewController: IMessageEnabledViewController {
    var presenter: IPeoplePresenter! { get set }
    var searchTerm: String! { get set }
    var navigationController: UINavigationController? { get }
    
    func reloadData()
    func showActivityIndicator()
    func hideActivityIndicator()
}

class PeopleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IPeopleListViewController {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
