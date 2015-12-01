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
    var name: String! { get set }
    var picUrl: String! { get set }

    func reloadMenu()
    func hideMenu()
    func navigateToHome()
    func showActivityIndicator()
    func hideActivityIndicator()
}

@objc public enum MenuItem: Int {
    case Login
    case Events
    case Venues
    case People
    case MyProfile
}

class MenuViewController: UIViewController, IMenuViewController, UITextFieldDelegate {

    var presenter: IMenuPresenter!
    var session: ISession!
    
    private var picUrlInternal: String!
    
    var name: String!{
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
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
                pictureImageView.image = UIImage(named: "generic-user-avatar")
            }
            
            pictureImageView.layer.borderWidth = 0.88;
            pictureImageView.layer.borderColor = UIColor(red: 215/255, green: 226/255, blue: 235/255, alpha: 1.0).CGColor
            pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
            pictureImageView.clipsToBounds = true;
        }
    }
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var venuesButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    
    //@IBOutlet weak var searchTermTextView: UITextField!
    
    @IBAction func toggleMenuSelection(sender: UIButton) {
        eventsButton.alpha = 0.5
        venuesButton.alpha = 0.5
        peopleButton.alpha = 0.5
        myProfileButton.alpha = 0.5
        sender.alpha = 1
    }
    
    @IBAction func login(sender: UIButton) {
        if (presenter.hasAccessToMenuItem(MenuItem.Login)) {
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        myProfileButton.hidden = !presenter.hasAccessToMenuItem(MenuItem.MyProfile)
        
        if presenter.hasAccessToMenuItem(MenuItem.Login) {
            loginButton.setTitle("LOG IN", forState: UIControlState.Normal)
        } else {
            loginButton.setTitle("LOG OUT", forState: UIControlState.Normal)
        }
    }
    
    func navigateToHome() {
        toggleMenuSelection(eventsButton)
        performSegueWithIdentifier("eventsSegue", sender: self)
    }
    
    func showActivityIndicator() {
        SwiftSpinner.show("Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "searchSegue") {
            //session.set(Constants.SessionKeys.SearchTerm, value: searchTermTextView.text)
        }
    }
    
    /*
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTermTextView.resignFirstResponder()
        if !searchTermTextView.text!.isEmpty {
            performSegueWithIdentifier("searchSegue", sender: self)
        }
        return true
    }*/
}
