//
//  PeopleListViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

internal class PeopleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShowActivityIndicatorProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var peopleListView: PeopleListView!
    
    // MARK: - Properties
    
    var searchTerm: String = ""
    
    // MARK: - Loading
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        peopleListView.tableView.setContentOffset(CGPointZero, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peopleListView.tableView.registerNib(R.nib.peopleTableViewCell)
    }
    
    // MARK: - Methods
    
    func reloadData() {
        peopleListView.tableView.delegate = self
        peopleListView.tableView.dataSource = self
        peopleListView.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getPeopleCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell)!
        presenter.buildScheduleCell(cell, index: indexPath.row)
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showPersonProfile(indexPath.row)
    }
}