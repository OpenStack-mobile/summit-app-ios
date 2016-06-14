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
import AeroGearOAuth2

@objc
public protocol IMenuViewController: MessageEnabledViewController {
    var name: String! { get set }
    var picUrl: String! { get set }

    func reloadMenu()
    func hideMenu()
    func highlight(item: MenuItem)
    func navigateToHome()
    func navigateToMyProfile()
    func showActivityIndicator()
    func hideActivityIndicator()
}

@objc
public enum MenuItem: Int {
    case None
    case Login
    case Events
    case Venues
    case People
    case Attendees
    case MyProfile
    case About
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
            
            #if DEBUG
                picUrlInternal = newValue.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
            #else
                picUrlInternal = newValue
            #endif

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
    @IBOutlet weak var aboutButton: UIButton!
    
    @IBOutlet weak var searchTextView: UITextField!

    private func unselectMenuItems() {
        eventsButton.alpha = 0.5
        venuesButton.alpha = 0.5
        peopleButton.alpha = 0.5
        myProfileButton.alpha = 0.5
        aboutButton.alpha = 0.5
    }
    
    func highlight(item: MenuItem) {
        
        unselectMenuItems()
        
        switch item {
        case .Events:
            eventsButton.alpha = 1
        case .Venues:
            venuesButton.alpha = 1
        case .People:
            peopleButton.alpha = 1
        case .MyProfile:
            myProfileButton.alpha = 1
        case .About:
            aboutButton.alpha = 1
        default:
            break
        }
    }
    
    @IBAction func toggleMenuSelection(sender: UIButton) {
        
        var item: MenuItem = .None
        
        switch sender {
        case eventsButton:
            presenter.showEvents()
            item = .Events
        case venuesButton:
            presenter.showVenues()
            item = .Venues
        case peopleButton:
            presenter.showPeopleOrSpeakers()
            item = .People
        case myProfileButton:
            presenter.showMyProfile()
            item = .MyProfile
        case aboutButton:
            presenter.showAbout()
            item = .About
        default:
            break
        }
        
        highlight(item)
    }
    
    @IBAction func login(sender: UIButton) {
        if (presenter.hasAccessToMenuItem(MenuItem.Login)) {
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
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OAuth2Module.revokeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "revokedAccess:",
            name: OAuth2Module.revokeNotification,
            object: nil)
        
        presenter.viewLoad()
    }
    
    func revealController(revealController: SWRevealViewController, willMoveToPosition position:FrontViewPosition) {
        if let navigationController = revealController.frontViewController {
            if let viewController = navigationController.childViewControllers.first {
                viewController.view.userInteractionEnabled = position != FrontViewPosition.Right
            }
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
    
    func navigateToMyProfile() {
        toggleMenuSelection(myProfileButton)
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
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.searchTextView.text = ""
            }
        }
        return true
    }
    
    func revokedAccess(notification: NSNotification) {
        presenter.revokedAccess()
        showInfoMessage("Session expired", message: "Your session expired, please log in again using your credentials")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OAuth2Module.revokeNotification, object: nil)
    }
}
