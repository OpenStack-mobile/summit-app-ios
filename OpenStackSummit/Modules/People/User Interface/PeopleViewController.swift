//
//  PeopleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IPeopleViewController {
    var presenter: IPeoplePresenter! { get set }
    var searchTerm: String! { get set }
    var people: [PersonListItemDTO]! { get set }
    
    func reloadData()
    func showErrorMessage(error: NSError)
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let person = people![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PeopleTableViewCell
        
        cell.nameLabel.text = person.name
        cell.titleLabel.text = person.title;
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        self.presenter.showPersonProfile(indexPath.row)
    }
}
