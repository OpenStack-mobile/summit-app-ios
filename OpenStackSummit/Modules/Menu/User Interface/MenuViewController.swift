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
    var picUrl: String! { get set }

    func reloadMenu()
    func hideMenu()
    func navigateToHome()
    func showActivityIndicator()
    func hideActivityIndicator()
}

class MenuViewController: UIViewController, IMenuViewController, UITextFieldDelegate {

    var presenter: IMenuPresenter!
    var session: ISession!
    
    private var picUrlInternal: String!
    
    var picUrl: String! {
        get {
            return picUrlInternal
        }
        set {
            picUrlInternal = newValue.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
            if (!picUrlInternal.isEmpty) {
                pictureImageView.hnk_setImageFromURL(NSURL(string: picUrlInternal)!)
            }
            else {
                pictureImageView.hnk_setImageFromURL(NSURL(string: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQsKM4aXdIlZmlLHSonqBq9UsESy4WQidH3Dqa3NeeL4qgPzAq70w")!)
            }
            
            pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
            pictureImageView.clipsToBounds = true;
        }
    }
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var venuesButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    
    //@IBOutlet weak var searchTermTextView: UITextField!
    
    @IBAction func buttonPressed(sender: UIButton) {
        eventsButton.alpha = 0.5
        venuesButton.alpha = 0.5
        peopleButton.alpha = 0.5
        myProfileButton.alpha = 0.5
        sender.alpha = 1
    }
    
    @IBAction func login(sender: UIButton) {
        if (loginButton.currentTitle == "LOGIN") {
            SwiftSpinner.show("Please wait...")
            presenter.login()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.hideActivityIndicator()
            }
        } else {
            presenter.logout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //searchTermTextView.delegate = self
        presenter.viewLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    func hideMenu() {
        revealViewController().revealToggle(self)
    }
    
    func reloadMenu() {        
        myProfileButton.hidden = !presenter.hasAccessToMenuItem(myProfileButton.currentTitle!)
        if presenter.hasAccessToMenuItem("login") {
            loginButton.setTitle("LOGIN", forState: UIControlState.Normal)
        } else {
            loginButton.setTitle("LOGOUT", forState: UIControlState.Normal)
        }
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
    
    /*override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.hideActivityIndicator()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "searchSegue") {
            //session.set(Constants.SessionKeys.SearchTerm, value: searchTermTextView.text)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTermTextView.resignFirstResponder()
        if !searchTermTextView.text!.isEmpty {
            performSegueWithIdentifier("searchSegue", sender: self)
        }
        return true
    }*/
}
