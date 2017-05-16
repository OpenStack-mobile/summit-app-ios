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
    
    @IBOutlet private(set) weak var searchTextView: UITextField!
    @IBOutlet private(set) weak var pictureImageView: UIImageView!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var loginButton: UIButton!
    
    @IBOutlet private(set) weak var eventsButton: UIButton!
    @IBOutlet private(set) weak var venuesButton: UIButton!
    @IBOutlet private(set) weak var peopleButton: UIButton!
    @IBOutlet private(set) weak var myProfileButton: UIButton!
    @IBOutlet private(set) weak var aboutButton: UIButton!
    @IBOutlet private(set) weak var inboxButton: UIButton!
    @IBOutlet private(set) weak var inboxCounterView: UIView!
    @IBOutlet private(set) weak var inboxCounterLabel: UILabel!
    
    // MARK: - Properties
    
    // Menu VCs
    lazy var generalScheduleViewController: GeneralScheduleViewController = R.storyboard.schedule.generalScheduleViewController()!
    lazy var venuesViewController: VenuesViewController = VenuesViewController()
    lazy var speakersViewController: SpeakersViewController = R.storyboard.people.speakersViewController()!
    
    private var unreadNotificationsObserver: Int?
    private var unreadTeamMessagesObserver: Int?
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    // MARK: - Accessors
    
    private(set) var name: String {
        
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    private(set) var picture: URL? {
        
        didSet {
            
            let placeholder = #imageLiteral(resourceName: "generic-user-avatar")
            
            if let url = picture {
                
                pictureImageView.hnk_setImageFromURL(url.environmentScheme, placeholder: placeholder)
                
            } else {
                
                pictureImageView.image = #imageLiteral(resourceName: "generic-user-avatar")
            }
            
            pictureImageView.layer.borderWidth = 0.88;
            pictureImageView.layer.borderColor = UIColor(red: 215/255, green: 226/255, blue: 235/255, alpha: 1.0).cgColor
            pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
            pictureImageView.clipsToBounds = true;
        }
    }
    
    // MARK: - Loading
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        
        if let observer = unreadTeamMessagesObserver {
            
            PushNotificationManager.shared.unreadTeamMessages.remove(observer)
        }
        
        if let observer = unreadNotificationsObserver {
            
            PushNotificationManager.shared.unreadNotifications.remove(observer)
        }
        
        NotificationCenter.default.removeObserver(self)
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
        /*
        NotificationCenter.default.removeObserver(self, name: OAuth2Module.revokeNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MenuViewController.revokedAccess(_:)),
            name: OAuth2Module.revokeNotification,
            object: nil)
        */
        
        // observe unread notifications
        unreadTeamMessagesObserver = PushNotificationManager.shared.unreadTeamMessages
            .observe { [weak self] _ in self?.reloadInboxCounter() }
        unreadNotificationsObserver = PushNotificationManager.shared.unreadNotifications
            .observe { [weak self] _ in self?.reloadInboxCounter() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showUserProfile()
        self.reloadMenu()
        self.reloadInboxCounter()
    }
    
    // MARK: - Actions
    
    @IBAction func toggleMenuSelection(_ sender: UIButton) {
        
        let item: MenuItem
        
        switch sender {
            
        case eventsButton:
            showEvents()
            item = .events
            
        case venuesButton:
            showVenues()
            item = .venues
            
        case peopleButton:
            showSpeakers()
            item = .people
            
        case myProfileButton:
            showMyProfile()
            item = .myProfile
            
        case aboutButton:
            showAbout()
            item = .about
            
        case inboxButton:
            showInbox()
            item = .inbox
            
        default: fatalError("Invalid sender \(sender)")
        }
        
        highlight(item)
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        if (hasAccess(to: .login)) {
            login()
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
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
        case .myProfile:
            return currentMemberRole != .anonymous
        case .login:
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
    
    private func highlight(_ item: MenuItem) {
        
        let _ = self.view
        
        unselectMenuItems()
        
        switch item {
        case .events:
            eventsButton.alpha = 1
        case .venues:
            venuesButton.alpha = 1
        case .people:
            peopleButton.alpha = 1
        case .myProfile:
            myProfileButton.alpha = 1
        case .about:
            aboutButton.alpha = 1
        case .inbox:
            inboxButton.alpha = 1
            
        // not applicable
        case .login: break
        }
    }
    
    @inline(__always)
    private func hideMenu() {
        revealViewController().revealToggle(self)
    }
    
    private func reloadMenu() {
        
        let loginTitle = hasAccess(to: .login) ? "LOG IN" : "LOG OUT"
        loginButton.setTitle(loginTitle, for: UIControlState())
        
        peopleButton.setTitle("SPEAKERS", for: UIControlState())
        
        myProfileButton.isHidden = hasAccess(to: .myProfile) == false
    }
    
    private func reloadInboxCounter() {
        
        let unreadCount = PushNotificationManager.shared.unreadCount
        
        inboxCounterView.isHidden = unreadCount == 0
        inboxCounterView.layer.cornerRadius = inboxCounterView.frame.size.width / 2
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
                picture = speaker.picture
                
            } else {
                
                name = currentMember.name
                picture = currentMember.picture
            }
            
        } else {
            
            name = ""
            picture = nil
        }
    }
    
    func showSpeakers() {
        
        highlight(.people)
        
        show(speakersViewController)
    }
    
    func showEvents() {
        
        highlight(.events)
        
        show(generalScheduleViewController)
    }
    
    func showVenues() {
        
        highlight(.venues)
        
        show(venuesViewController)
    }
    
    func showAbout() {
        
        highlight(.about)
        
        let aboutViewController = R.storyboard.menu.aboutViewController()!
        
        show(aboutViewController)
    }
    
    func showInbox() {
        
        highlight(.inbox)
        
        let teamsViewController = InboxViewController()
        
        show(teamsViewController)
    }
        
    private func showMyProfile() {
        
        guard Store.shared.isLoggedIn else { return }
        
        highlight(.myProfile)
        
        let myProfileViewController = MyProfileViewController()
        
        show(myProfileViewController)
    }
    
    private func show(_ viewController: UIViewController) {
        
        let revealViewController = self.revealViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        revealViewController?.pushFrontViewController(navigationController, animated: true)
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
            DispatchQueue.main.async(execute: {
                
                self.showActivityIndicator()
            })
            
        }) { [weak self] (response) in
            
            guard let controller = self else { return }
            
            OperationQueue.main.addOperation {
                
                controller.hideMenu()
                
                controller.dismissActivityIndicator()
                
                switch response {
                    
                case let .some(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                case .none:
                    
                    controller.showUserProfile()
                    controller.reloadMenu()
                    
                    if Store.shared.isLoggedInAndConfirmedAttendee {
                        
                        Preference.goingToSummit = true
                        
                        // reload schedule
                        controller.showEvents()
                       
                    } else {
                        
                        controller.showMyProfile()
                        
                        let revealViewController = controller.revealViewController()
                        
                        // show a popup asking user if they are going to the summit
                        let alert = UIAlertController(title: "Eventbrite Order", message: "Are you a summit attendee?", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "No", style: .default) { (action) in
                            
                            Preference.goingToSummit = false
                        })
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (action) in
                            
                            Preference.goingToSummit = true
                            
                            let viewController = R.storyboard.member.attendeeConfirmNavigationController()!
                            
                            revealViewController!.present(viewController, animated: true) { controller.showMyProfile() }
                        })
                        
                        revealViewController?.present(alert, animated: true) { }
                    }
                    
                    // log user email
                    if let userID = Store.shared.authenticatedMember?.id, AppEnvironment == .staging {
                        
                        Crashlytics.sharedInstance().setUserIdentifier("\(userID)")
                    }
                }
            }
        }
    }
    
    private func logout() {
        
        Store.shared.logout()
        
        // log user email
        if AppEnvironment == .staging {
            
            Crashlytics.sharedInstance().setUserIdentifier(nil)
        }
        
        showUserProfile()
        navigateToHome()
        reloadMenu()
        hideMenu()
        dismissActivityIndicator()
    }
    
    // MARK: - SWRevealViewControllerDelegate
    
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition) {
        
        if let navigationController = revealController.frontViewController {
            if let viewController = navigationController.childViewControllers.first {
                viewController.view.isUserInteractionEnabled = position != FrontViewPosition.right
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchTextView.resignFirstResponder()
        
        let term = searchTextView.text ?? ""
        
        if term.isEmpty == false {
            
            unselectMenuItems()
            
            guard try! Store.shared.managedObjectContext.managedObjects(SummitManagedObject.self).count > 0 else {
                
                showInfoMessage("Info", message: "No summit data available")
                return true
            }
            
            defer {
                
                let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.searchTextView.text = ""
                }
            }
            
            let sanitizedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // show Search VC
            search(sanitizedTerm)
        }
        
        return true
    }
    
    // MARK: - SummitActivityHandling
    
    func view(screen: AppActivityScreen) {
        
        switch screen {
        case .venues: showVenues()
        case .events: showEvents()
        case .speakers: showSpeakers()
        case .about: showAbout()
        case .inbox: showInbox()
        }
    }
    
    func search(_ searchTerm: String) {
        
        let searchViewController = R.storyboard.menu.searchViewController()!
        searchViewController.searchTerm = searchTerm
        
        show(searchViewController)
    }
    
    // MARK: - Notifications
    
    @objc private func revokedAccess(_ notification: Foundation.Notification) {
        
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
    
    case login
    case events
    case venues
    case people
    case about
    case inbox
    case myProfile
}
