//
//  MenuViewController.swift
//  OpenStackSched
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner

@objc
public protocol IMenuViewController: IMessageEnabledViewController {
    func reloadMenu()
    func hideMenu()
    func navigateToHome()
    func showActivityIndicator()
    func hideActivityIndicator()
}

class MenuViewController: UITableViewController, IMenuViewController, UITextFieldDelegate {

    var presenter: IMenuPresenter!
    var session: ISession!
    
    @IBOutlet weak var searchTermTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTermTextView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    func hideMenu() {
        revealViewController().revealToggle(self)
    }
    
    func reloadMenu() {
        SwiftSpinner.hide()
        tableView.reloadData()
    }
    
    func navigateToHome() {
        //performSegueWithIdentifier("generalScheduleSegue", sender: self)
    }
    
    func showActivityIndicator() {
        SwiftSpinner.show("Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell : UITableViewCell = super.tableView(tableView, cellForRowAtIndexPath:indexPath)
        
        let hidden = !presenter.hasAccessToMenuItem(indexPath.section, row: indexPath.row)
        cell.hidden = hidden
        
        if (cell.hidden) {
            return 0;
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath:indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        if (indexPath.section == 2 && indexPath.row == 2) {
            presenter.logout()
        }
        else if (indexPath.section == 2 && indexPath.row == 1) {
            SwiftSpinner.show("Please wait...")
            presenter.login()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "searchSegue") {
            session.set(Constants.SessionKeys.SearchTerm, value: searchTermTextView.text)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTermTextView.resignFirstResponder()
        if !searchTermTextView.text!.isEmpty {
            performSegueWithIdentifier("searchSegue", sender: self)
        }
        return true
    }
}
