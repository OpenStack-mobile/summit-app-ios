//
//  MenuViewController.swift
//  OpenStackSched
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearOAuth2
import CoreSummit
import Crashlytics
import JGProgressHUD

final class MenuViewController: UIViewController, UITextFieldDelegate, ActivityViewController, SWRevealViewControllerDelegate, MessageEnabledViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var searchTextView: UITextField!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var venuesButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var inboxButton: UIButton!
    @IBOutlet weak var inboxCounterView: UIView!
    @IBOutlet weak var inboxCounterLabel: UILabel!
    
    // MARK: - Properties
    
    // Menu VCs
    lazy var generalScheduleViewController: GeneralScheduleViewController = R.storyboard.schedule.generalScheduleViewController()!
    lazy var venuesViewController: VenuesViewController = VenuesViewController()
    lazy var speakersViewController: SpeakersViewController = R.storyboard.people.speakersViewController()!
    
    private var unreadNotificationsObserver: Int?
    private var unreadTeamMessagesObserver: Int?
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .Dark)
    
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
            
            let picURLInternal: String
            
            if AppEnvironment == .Staging {
                
                picURLInternal = pictureURL.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
            } else {
                
                picURLInternal = pictureURL
            }

            if picURLInternal.isEmpty == false {
                pictureImageView.hnk_setImageFromURL(NSURL(string: picURLInternal)!)
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
        return .LightContent
    }
    
    deinit {
        
        if let observer = unreadTeamMessagesObserver {
            
            PushNotificationManager.shared.unreadTeamMessages.remove(observer)
        }
        
        if let observer = unreadNotificationsObserver {
            
            PushNotificationManager.shared.unreadNotifications.remove(observer)
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextView.attributedPlaceholder = NSAttributedString(string: "Type to search...", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.5)])
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
        
        // observe unread notifications
        unreadTeamMessagesObserver = PushNotificationManager.shared.unreadTeamMessages
            .observe { [weak self] _ in self?.reloadInboxCounter() }
        unreadNotificationsObserver = PushNotificationManager.shared.unreadNotifications
            .observe { [weak self] _ in self?.reloadInboxCounter() }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showUserProfile()
        self.reloadMenu()
        self.reloadInboxCounter()
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
            
        case inboxButton:
            showInbox()
            item = .Inbox
            
        default: fatalError("Invalid sender \(sender)")
        }
        
        highlight(item)
    }
    
    @IBAction func login(sender: UIButton) {
        
        if (hasAccess(to: .Login)) {
            login()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.dismissActivityIndicator()
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
        inboxButton.alpha = 0.5
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
        case .Inbox:
            inboxButton.alpha = 1
            
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
    
    private func reloadInboxCounter() {
        
        let unreadCount = PushNotificationManager.shared.unreadCount
        
        inboxCounterView.hidden = unreadCount == 0
        inboxCounterLabel.text = "\(unreadCount)"
    }
    
    // MARK: Navigation
    
    @inline(__always)
    private func navigateToHome() {
        
        toggleMenuSelection(eventsButton)
    }
    
    private func showUserProfile() {
        
        if let memberManagedObject = Store.shared.authenticatedMember {
            
            let currentMember = Member(managedObject: memberManagedObject)
            
            if let speaker = currentMember.speakerRole {
                
                name = speaker.name
                pictureURL = speaker.pictureURL
                
            } else {
                
                name = currentMember.name
                pictureURL = currentMember.pictureURL
            }
            
        } else if Store.shared.isLoggedIn {
            
            name = Store.shared.session.name ?? ""
            pictureURL = ""
            
        } else {
            
            name = ""
            pictureURL = ""
        }
    }
    
    func showSpeakers() {
        
        highlight(.People)
        
        show(speakersViewController)
    }
    
    func showEvents() {
        
        highlight(.Events)
        
        show(generalScheduleViewController)
    }
    
    func showVenues() {
        
        highlight(.Venues)
        
        show(venuesViewController)
    }
    
    func showAbout() {
        
        highlight(.About)
        
        let aboutViewController = R.storyboard.menu.aboutViewController()!
        
        show(aboutViewController)
    }
    
    func showInbox() {
        
        highlight(.Inbox)
        
        let teamsViewController = InboxViewController()
        
        show(teamsViewController)
    }
    
    func showSearch(for term: String) {
        
        let searchViewController = R.storyboard.menu.searchViewController()!
        searchViewController.searchTerm = term
        
        show(searchViewController)
    }
        
    private func showMyProfile() {
        
        guard Store.shared.isLoggedIn else { return }
        
        highlight(.MyProfile)
        
        let myProfileViewController = MyProfileViewController()
        
        show(myProfileViewController)
    }
    
    private func show(viewController: UIViewController) {
        
        let revealViewController = AppDelegate.shared.revealViewController
        let navigationController = UINavigationController(rootViewController: viewController)
        
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    // MARK: Login / Logout
    
    private func login() {
        
        let summit = SummitManager.shared.summit.value
        
        guard self.isDataLoaded
            else { showInfoMessage("Info", message: "Summit data is required to log in."); return }
        
        showActivityIndicator()
        
        Preference.goingToSummit = false
        
        Store.shared.login(summit, loginCallback: {
            
            // return from SafariVC
            dispatch_async(dispatch_get_main_queue(), {
                
                self.showActivityIndicator()
            })
            
        }) { [weak self] (response) in
            
            guard let controller = self else { return }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                controller.hideMenu()
                
                controller.dismissActivityIndicator()
                
                switch response {
                    
                case let .Some(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                case .None:
                    
                    controller.showUserProfile()
                    controller.reloadMenu()
                    
                    if Store.shared.isLoggedInAndConfirmedAttendee {
                        
                        Preference.goingToSummit = true
                        
                        // reload schedule
                        controller.showEvents()
                       
                    } else {
                        
                        controller.showMyProfile()
                        
                        let revealViewController = AppDelegate.shared.revealViewController
                        
                        // show a popup asking user if they are going to the summit
                        let alert = UIAlertController(title: "Eventbrite Order", message: "Are you a summit attendee?", preferredStyle: .Alert)
                        
                        alert.addAction(UIAlertAction(title: "No", style: .Default) { (action) in
                            
                            Preference.goingToSummit = false
                        })
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .Default) { (action) in
                            
                            Preference.goingToSummit = true
                            
                            let viewController = R.storyboard.member.attendeeConfirmNavigationController()!
                            
                            revealViewController.presentViewController(viewController, animated: true) { controller.showMyProfile() }
                        })
                        
                        revealViewController.presentViewController(alert, animated: true) { }
                    }
                    
                    // log user email
                    if let userID = Store.shared.authenticatedMember?.identifier
                        where AppEnvironment == .Staging {
                        
                        Crashlytics.sharedInstance().setUserIdentifier("\(userID)")
                    }
                }
            }
        }
    }
    
    private func logout() {
        
        Store.shared.logout()
        
        // log user email
        if AppEnvironment == .Staging {
            
            Crashlytics.sharedInstance().setUserIdentifier(nil)
        }
        
        showUserProfile()
        navigateToHome()
        reloadMenu()
        hideMenu()
        dismissActivityIndicator()
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
            
            guard try! Store.shared.managedObjectContext.managedObjects(SummitManagedObject).count > 0 else {
                
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
        
        // logout in case its not cleared
        Store.shared.session.clear()
        
        showUserProfile()
        navigateToHome()
        reloadMenu()
        hideMenu()
        dismissActivityIndicator()
        
        showInfoMessage("Session expired", message: "Your session expired, please log in again using your credentials")
    }
}

// MARK: - Supporting Types

enum MenuItem {
    
    case Login
    case Events
    case Venues
    case People
    case About
    case Inbox
    case MyProfile
}
