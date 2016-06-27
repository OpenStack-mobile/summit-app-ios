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
import CoreSummit

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

final class MenuViewController: UIViewController, UITextFieldDelegate, ShowActivityIndicatorProtocol, SWRevealViewControllerDelegate, MessageEnabledViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var venuesButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    @IBOutlet weak var searchTextView: UITextField!
    
    // MARK: - Accessors
    
    private(set) var name: String {
        
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    private(set) var pictureURL: String = "" {
        
        didSet {
            
            /*
            #if DEBUG
                picUrlInternal = newValue.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
            #else
                picUrlInternal = newValue
            #endif*/

            if (!pictureURL.isEmpty) {
                pictureImageView.hnk_setImageFromURL(NSURL(string: pictureURL)!)
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
    
    // MARK: - Loading
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextView.delegate = self
        
        // setup reveal VC
        revealViewController().delegate = self
        revealViewController().rearViewRevealWidth = 264
        revealViewController().view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        // session notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OAuth2Module.revokeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(MenuViewController.revokedAccess(_:)),
            name: OAuth2Module.revokeNotification,
            object: nil)
        
        
        if Store.shared.authenticatedMember == nil {
            // TODO: move this to launch screen or landing page
            unsubscribeFromPushChannels() { (succeeded: Bool, error: NSError?) in
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                }
            }
        }
        
        self.showUserProfile()
        self.reloadMenu()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    // MARK: - Actions
    
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
    
    // MARK: - Private Methods

    private func unselectMenuItems() {
        eventsButton.alpha = 0.5
        venuesButton.alpha = 0.5
        peopleButton.alpha = 0.5
        myProfileButton.alpha = 0.5
        aboutButton.alpha = 0.5
    }
    
    private func highlight(item: MenuItem) {
        
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
    
    @inline(__always)
    func hideMenu() {
        revealViewController().revealToggle(self)
    }
    
    func reloadMenu() {
        
        let title: String
        
        title = presenter.hasAccessToMenuItem(MenuItem.Login) ? "LOG IN" : "LOG OUT"
        loginButton.setTitle(title, forState: UIControlState.Normal)
        
        title = presenter.hasAccessToMenuItem(MenuItem.Attendees) ? "PEOPLE" : "SPEAKERS"
        peopleButton.setTitle(title, forState: UIControlState.Normal)
        
        myProfileButton.hidden = !presenter.hasAccessToMenuItem(MenuItem.MyProfile)
    }
    
    @inline(__always)
    func navigateToHome() {
        toggleMenuSelection(eventsButton)
    }
    
    @inline(__always)
    func navigateToMyProfile() {
        toggleMenuSelection(myProfileButton)
    }
    
    // MARK: - SWRevealViewControllerDelegate
    
    func revealController(revealController: SWRevealViewController, willMoveToPosition position: FrontViewPosition) {
        if let navigationController = revealController.frontViewController {
            if let viewController = navigationController.childViewControllers.first {
                viewController.view.userInteractionEnabled = position != FrontViewPosition.Right
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        searchTextView.resignFirstResponder()
        
        let term = searchTextView.text ?? ""
        
        if term.isEmpty == false {
            
            unselectMenuItems()
            
            guard Store.shared.realm.objects(RealmSummit).count > 0 else {
                
                showInfoMessage("Info", message: "No summit data available")
                return true
            }
            
            defer {
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.searchTextView.text = ""
                }
            }
            
            let sanitizedTerm = term.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
            
            // show Search VC
            
        }
        
        return true
    }
    
    // MARK: - Notifications
    
    @objc private func revokedAccess(notification: NSNotification) {
        
        //presenter.revokedAccess()
        showInfoMessage("Session expired", message: "Your session expired, please log in again using your credentials")
    }
}
