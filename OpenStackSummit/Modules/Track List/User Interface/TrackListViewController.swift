//
//  TrackListViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackListViewController {
    var searchTerm: String! { get set }
    var navigationController: UINavigationController? { get }
    
    func reloadData()
    func showErrorMessage(error: NSError)
}


class TrackListViewController: RevealViewController, UITableViewDelegate, UITableViewDataSource, ITrackListViewController {
    var presenter: ITrackListPresenter!
    var searchTerm: String!
    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "trackTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewLoad()
    }
    
    func reloadData() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showErrorMessage(error: NSError) {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getTrackCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TrackTableViewCell
        presenter.buildScheduleCell(cell, index: indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showTrackEvents(indexPath.row)
    }


}
