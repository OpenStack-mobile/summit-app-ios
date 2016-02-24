//
//  MenuPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMenuPresenter {
    func viewLoad()
    func hasAccessToMenuItem(item: MenuItem) -> Bool
    func login()
    func logout()
    func showSearchResults()
    func showEvents()
    func showVenues()
    func showPeopleOrSpeakers()
    func showMyProfile()
}

public class MenuPresenter: NSObject, IMenuPresenter {
    var interactor: IMenuInteractor!
    var wireframe: IMenuWireframe!
    var viewController: IMenuViewController!
    var securityManager: SecurityManager!
    
    public override init() {
        super.init()
    }
    
    public init(interactor: IMenuInteractor, menuWireframe: IMenuWireframe, viewController: IMenuViewController, securityManager: SecurityManager) {
        self.interactor = interactor
        self.wireframe = menuWireframe
        self.viewController = viewController
        self.securityManager = securityManager
    }
    
    public func viewLoad() {
        if securityManager.getCurrentMember() == nil {
            // TODO: move this to launch screen or landing page
            interactor.unsubscribeFromPushChannels() { (succeeded: Bool, error: NSError?) in
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                }
            }
        }
        
        self.showUserProfile()
        self.viewController.reloadMenu()
    }
    
    public func hasAccessToMenuItem(item: MenuItem) -> Bool {
        
        let currentMemberRole = securityManager.getCurrentMemberRole()
        
        var show: Bool
        switch (item) {
            case .MyProfile:
                show = currentMemberRole != MemberRoles.Anonymous
            case .Login:
                show = currentMemberRole == MemberRoles.Anonymous
            case .Attendees:
                show = false
            default:
                show = true
        }
        return show

    }
    
    public func login() {
        viewController.showActivityIndicator()
        viewController.hideMenu()
        
        interactor.login { error in
            //defer { self.viewController.hideActivityIndicator() }
            
            if error != nil {
                if error!.code == 404 {
                    let notAttendeeError = NSError(domain: "You're not a summit attendee. You have to be registered as summit attendee in order to login", code: 2001, userInfo: nil)
                    self.viewController.showErrorMessage(notAttendeeError)
                }
                else {
                    self.viewController.showErrorMessage(error!)
                }
                return
            }
            
            self.showUserProfile()
            self.viewController.reloadMenu()
            self.viewController.hideActivityIndicator()
        }
    }
    
    public func logout() {
        viewController.showActivityIndicator()

        interactor.logout() {error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            self.showPersonProfile(PersonDTO(), error: nil)
            
            self.viewController.navigateToHome()
            self.viewController.reloadMenu()
            self.viewController.hideMenu()
            self.viewController.hideActivityIndicator()
        }
    }
    
    public func showSearchResults() {
        wireframe.showSearchResults()
    }
    
    public func showEvents() {
        wireframe.showEvents()
    }
    
    public func showVenues() {
        wireframe.showVenues()
    }
    
    public func showPeopleOrSpeakers() {
        if hasAccessToMenuItem(MenuItem.Attendees) {
            wireframe.showPeople()
        }
        else {
            wireframe.showSpeakers()
        }
    }
    
    public func showMyProfile() {
        if let _ = interactor.getCurrentMember() {
            wireframe.showMyProfile(0)
        }
    }
    
    func showUserProfile() {
        if let currentMember = interactor.getCurrentMember() {
            if currentMember.speakerRole != nil {
                showPersonProfile(currentMember.speakerRole!, error: nil)
            }
            else {
                showPersonProfile(currentMember.attendeeRole!, error: nil)
            }
        }
        else {
            showPersonProfile(PersonDTO(), error: nil)
        }
    }
    
    func showPersonProfile(person: PersonDTO?, error: NSError? = nil) {
        dispatch_async(dispatch_get_main_queue(),{
            self.viewController.name = person!.name
            self.viewController.picUrl = person!.pictureUrl
        })
    }
}
