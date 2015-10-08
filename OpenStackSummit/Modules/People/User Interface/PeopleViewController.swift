//
//  PeopleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner

@objc
public protocol IPeopleViewController {
    var presenter: IPeoplePresenter! { get set }
    var searchTerm: String! { get set }
    var people: [PersonListItemDTO]! { get set }
    
    func reloadData()
    func showErrorMessage(error: NSError)
    func showActivityIndicator()
    func hideActivityIndicator()    
}

class PeopleViewController: RevealViewController, UITableViewDelegate, UITableViewDataSource, IPeopleViewController {
    var presenter: IPeoplePresenter!
    var searchTerm: String!
    var people: [PersonListItemDTO]!    
    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "peopleTableViewCell"

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
        presenter.buildCell(cell, index: indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showPersonProfile(indexPath.row)
    }
}
