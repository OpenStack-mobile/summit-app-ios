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

            if pictureURL.isEmpty == false {
                pictureImageView.hnk_setImageFromURL(NSURL(string: pictureURL)!)
            }
            else {
                pictureImageView.image = R.image.genericUserAvatar()!
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
            
            /*
            // TODO: move this to launch screen or landing page
            pushNotificationsManager.unsubscribeFromPushChannels { (succeeded: Bool, error: NSError?) in
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                }
            }*/
        }
        
        self.showUserProfile()
        self.reloadMenu()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    // MARK: - Actions
    
    @IBAction func toggleMenuSelection(sender: UIButton) {
        
        let item: MenuItem
        
        switch sender {
        case eventsButton:
            showEvents()
            item = .Events
        case venuesButton:
            showVenues()
            item = .Venues
        case peopleButton:
            showSpeakers()
            item = .People
        case myProfileButton:
            showMyProfile()
            item = .MyProfile
        case aboutButton:
            showAbout()
            item = .About
        default: fatalError("Invalid sender \(sender)")
        }
        
        highlight(item)
    }
    
    @IBAction func login(sender: UIButton) {
        
        if (hasAccess(to: .Login)) {
            login()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.hideActivityIndicator()
            }
        } else {
            logout()
        }
    }
    
    // MARK: - Private Methods
    
    private func hasAccess(to menuItem: MenuItem) -> Bool {
        
        let currentMemberRole = Store.shared.memberRole
        
        switch (menuItem) {
        case .MyProfile:
            return currentMemberRole != .anonymous
        case .Login:
            return currentMemberRole == .anonymous
        default:
            return true
        }
    }

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
            
        // not applicable
        case .Login: break
        }
    }
    
    @inline(__always)
    private func hideMenu() {
        revealViewController().revealToggle(self)
    }
    
    private func reloadMenu() {
        
        let loginTitle = hasAccess(to: .Login) ? "LOG IN" : "LOG OUT"
        loginButton.setTitle(loginTitle, forState: .Normal)
        
        peopleButton.setTitle("SPEAKERS", forState: .Normal)
        
        myProfileButton.hidden = hasAccess(to: .MyProfile) == false
    }
    
    @inline(__always)
    private func navigateToHome() {
        toggleMenuSelection(eventsButton)
    }
    
    @inline(__always)
    private func navigateToMyProfile() {
        toggleMenuSelection(myProfileButton)
    }
    
    private func showUserProfile() {
        
        if let realmMember = Store.shared.authenticatedMember {
            
            let currentMember = Member(realmEntity: realmMember)
            
            if let speaker = currentMember.speakerRole {
                
                name = speaker.name
                pictureURL = speaker.pictureURL
                
            } else if let attendee = currentMember.attendeeRole {
                
                name = attendee.name
                pictureURL = attendee.pictureURL
                
            } else {
                
                name = currentMember.name
                pictureURL = currentMember.pictureURL
            }
            
        } else {
            
            name = ""
            pictureURL = ""
        }
    }
    
    // MARK: Navigation
    
    private func showSpeakers() {
        
        let speakersVC = R.storyboard.people.speakerListViewController()!
        let navigationController = AppDelegate.shared.navigationController
        let revealViewController = AppDelegate.shared.revealViewController
        
        navigationController.setViewControllers([speakersVC], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    private func showSearch(for term: String) {
        
        let searchViewController = R.storyboard.menu.searchViewController()!
        let navigationController = AppDelegate.shared.navigationController
        let revealViewController = AppDelegate.shared.revealViewController
        
        searchViewController.searchTerm = term
        navigationController.setViewControllers([searchViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    private func showEvents() {
        
        highlight(.Events)
        
        let eventsViewController = EventsViewController()
        let navigationController = AppDelegate.shared.navigationController
        let revealViewController = AppDelegate.shared.revealViewController
        
        navigationController.setViewControllers([eventsViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    private func showVenues() {
        
        let venuesViewController = VenuesViewController()
        let navigationController = AppDelegate.shared.navigationController
        let revealViewController = AppDelegate.shared.revealViewController
        
        navigationController.setViewControllers([venuesViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    private func showMyProfile() {
        
        if let _ = Store.shared.authenticatedMember {
            
            func isLoggedInAndConfirmedAttendee() -> Bool {
                /*
                let currentMemberId = session.get(kCurrentMemberId) as? Int
                return isLoggedIn() && currentMemberId != kLoggedInNotConfirmedAttendee;
                */ return false
            }
            
            if isLoggedInAndConfirmedAttendee() {
                
                /*
                navigationController.setViewControllers([myProfileViewController], animated: false)
                revealViewController.pushFrontViewController(navigationController, animated: true)*/
                
            } else {
                
                /*
                navigationController.setViewControllers([memberOrderConfirmViewController], animated: false)
                revealViewController.pushFrontViewController(navigationController, animated: true)*/
            }
        }
    }
    
    private func showAbout() {
        
        let aboutViewController = R.storyboard.menu.aboutViewController()!
        let navigationController = AppDelegate.shared.navigationController
        let revealViewController = AppDelegate.shared.revealViewController
        
        navigationController.setViewControllers([aboutViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    // MARK: Login / Logout
    
    private func login() {
        
        // FIXME: Implement login
    }
    
    private func logout() {
        
        
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
            showSearch(for: sanitizedTerm)
        }
        
        return true
    }
    
    // MARK: - Notifications
    
    @objc private func revokedAccess(notification: NSNotification) {
        
        //presenter.revokedAccess()
        showInfoMessage("Session expired", message: "Your session expired, please log in again using your credentials")
    }
}

// MARK: - Supporting Types

enum MenuItem {
    
    case Login
    case Events
    case Venues
    case People
    case MyProfile
    case About
}
