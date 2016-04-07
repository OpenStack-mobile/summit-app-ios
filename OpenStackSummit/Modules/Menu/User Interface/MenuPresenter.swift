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
    func searchFor(term: String)
    func showEvents()
    func showVenues()
    func showPeopleOrSpeakers()
    func showMyProfile()
    func revokedAccess()
}

public class MenuPresenter: NSObject, IMenuPresenter {
    var securityManager: SecurityManager!
    var session: ISession!
    var viewController: IMenuViewController!
    var interactor: IMenuInteractor!
    var wireframe: IMenuWireframe!
    
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
        if !interactor.isDataLoaded() {
            viewController.showInfoMessage("Info", message: "Summit data is required to log in  ")
            return
        }
        
        viewController.showActivityIndicator()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.viewController.hideActivityIndicator()
        }
        viewController.hideMenu()
        
        let completitionBlock: (error: NSError?) -> Void = { error in
            //defer { self.viewController.hideActivityIndicator() }
            
            if error != nil {
                self.viewController.showErrorMessage(error!)
                return
            }
            
            self.showUserProfile()
            self.viewController.reloadMenu()
            self.viewController.hideActivityIndicator()
            
            if !self.interactor.isLoggedInAndConfirmedAttendee() {
                self.viewController.navigateToMyProfile()
            }
        }
        
        let partialCompletitionBlock: (Void) -> Void = {
            dispatch_async(dispatch_get_main_queue(),{
                self.viewController.showActivityIndicator()
            })
        }
        
        interactor.login(completitionBlock, partialCompletitionBlock: partialCompletitionBlock)
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
    
    public func revokedAccess() {
        self.showPersonProfile(PersonDTO(), error: nil)
        
        self.viewController.navigateToHome()
        self.viewController.reloadMenu()
        self.viewController.hideMenu()
        self.viewController.hideActivityIndicator()
    }
    
    public func searchFor(term: String) {
        if !interactor.isDataLoaded() {
            viewController.showInfoMessage("Info", message: "No summit data available")
            return
        }
        let sanitizedTerm = term.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        wireframe.showSearchFor(sanitizedTerm)
    }
    
    public func showEvents() {
        wireframe.showEvents()
    }
    
    public func showVenues() {
        if !interactor.isDataLoaded() {
            viewController.showInfoMessage("Info", message: "No summit data available")
            return
        }
        wireframe.showVenues()
    }
    
    public func showPeopleOrSpeakers() {
        if !interactor.isDataLoaded() {
            viewController.showInfoMessage("Info", message: "No summit data available")
            return
        }
        if hasAccessToMenuItem(MenuItem.Attendees) {
            wireframe.showPeople()
        }
        else {
            wireframe.showSpeakers()
        }
    }
    
    public func showMyProfile() {
        if !interactor.isDataLoaded() {
            viewController.showInfoMessage("Info", message: "No summit data available")
            return
        }
        
        if let _ = interactor.getCurrentMember() {
            if interactor.isLoggedInAndConfirmedAttendee() {
                wireframe.showMyProfile()
            }
            else {
                wireframe.showMemberOrderConfirm()
            }
        }
    }
    
    func showUserProfile() {
        if let currentMember = interactor.getCurrentMember() {
            if currentMember.speakerRole != nil {
                showPersonProfile(currentMember.speakerRole!, error: nil)
            }
            else if currentMember.attendeeRole != nil {
                showPersonProfile(currentMember.attendeeRole!, error: nil)
            }
            else {
                showPersonProfile(currentMember, error: nil)
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
