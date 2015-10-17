//
//  MyFeedbackViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackGivenListViewController {
    func releoadList()
}

class FeedbackGivenListViewController: RevealViewController, UITableViewDelegate, UITableViewDataSource, IFeedbackGivenListViewController {
    
    let cellIdentifier = "feedbackGivenTableViewCell"
    @IBOutlet weak var tableView: UITableView!
    var presenter : IFeedbackGivenListPresenter!
    
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
        return presenter.getFeedbackCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FeedbackGivenTableViewCell
        presenter.buildFeedbackCell(cell, index: indexPath.row)
        return cell
    }
}
