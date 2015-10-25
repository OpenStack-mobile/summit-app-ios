//
//  VenueListViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueListViewController {
    func releoadList()
}

class VenueListViewController: RevealViewController, UITableViewDelegate, UITableViewDataSource, IVenueListViewController {
    
    let cellIdentifier = "venueListTableViewCell"
    @IBOutlet weak var tableView: UITableView!
    var presenter : IVenueListPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewLoad()
    }
    
    func releoadList() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func showErrorMessage(error: NSError) {
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getVenuesCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! VenueListTableViewCell
        presenter.buildVenueCell(cell, index: indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        presenter.showVenueDetail(indexPath.row)
    }
}
