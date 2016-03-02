//
//  MenuViewController.swift
//  OpenStackSched
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner
import SWRevealViewController

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

@objc
public enum MenuItem: Int {
    case Login
    case Events
    case Venues
    case People
    case Attendees
    case MyProfile
}

class MenuViewController: UIViewController, IMenuViewController, UITextFieldDelegate, SWRevealViewControllerDelegate {

    var presenter: IMenuPresenter!
    
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
    
    @IBOutlet weak var searchTextView: UITextField!
    
    private func unselectMenuItems() {
        eventsButton.alpha = 0.5
        venuesButton.alpha = 0.5
        peopleButton.alpha = 0.5
        myProfileButton.alpha = 0.5
    }
    
    @IBAction func toggleMenuSelection(sender: UIButton) {
        
        unselectMenuItems()
        
        sender.alpha = 1
        
        switch sender {
        case eventsButton:
            presenter.showEvents()
        case venuesButton:
            presenter.showVenues()
        case peopleButton:
            presenter.showPeopleOrSpeakers()
        case myProfileButton:
            presenter.showMyProfile()
        default:
            break
        }
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
        
        revealViewController().delegate = self
        revealViewController().rearViewRevealWidth = 264
        revealViewController().view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        searchTextView.delegate = self
        
        presenter.viewLoad()
    }
    
    func revealController(revealController: SWRevealViewController, willMoveToPosition position:FrontViewPosition) {
        if let frontViewController = revealController.frontViewController {
            frontViewController.view.userInteractionEnabled = position == FrontViewPosition.Left
        }
    }

    func hideMenu() {
        revealViewController().revealToggle(self)
    }
    
    func reloadMenu() {
        var title: String
        
        title = presenter.hasAccessToMenuItem(MenuItem.Login) ? "LOG IN" : "LOG OUT"
        loginButton.setTitle(title, forState: UIControlState.Normal)
        
        title = presenter.hasAccessToMenuItem(MenuItem.Attendees) ? "PEOPLE" : "SPEAKERS"
        peopleButton.setTitle(title, forState: UIControlState.Normal)
        
        myProfileButton.hidden = !presenter.hasAccessToMenuItem(MenuItem.MyProfile)
    }
    
    func navigateToHome() {
        toggleMenuSelection(eventsButton)
    }
    
    func showActivityIndicator() {
        SwiftSpinner.show("Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTextView.resignFirstResponder()
        if !searchTextView.text!.isEmpty {
            unselectMenuItems()
            presenter.searchFor(searchTextView.text!)
        }
        return true
    }
}
