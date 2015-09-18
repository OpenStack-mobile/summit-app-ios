//
//  MenuViewController.swift
//  OpenStackSched
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMenuViewController {
    func reloadMenu()
    func hideMenu()
    func navigateToHome()
}

class MenuViewController: UITableViewController, IMenuViewController {

    var presenter: IMenuPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    func hideMenu() {
        revealViewController().revealToggle(self)
    }
    
    func reloadMenu() {
        tableView.reloadData()
    }
    
    func navigateToHome() {
        performSegueWithIdentifier("generalScheduleSegue", sender: self)
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
        if (indexPath.section == 3 && indexPath.row == 5) {
            presenter.logout()
        }
        else if (indexPath.section == 3 && indexPath.row == 6) {
            presenter.login()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
