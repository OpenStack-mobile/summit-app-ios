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
    func hasAccessToMenuItem(withTitle: String) -> Bool
    func login()
    func logout()
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
        self.viewController.picUrl = ""
        
        if securityManager.getCurrentMember() == nil {
            // TODO: move this to launch screen or landing page
            interactor.unsubscribeFromPushChannels() { (succeeded: Bool, error: NSError?) in
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                }
            }
        }
        
        self.viewController.reloadMenu()
    }
    
    public func hasAccessToMenuItem(withTitle: String) -> Bool {
        
        let currentMemberRole = securityManager.getCurrentMemberRole()
        
        var show: Bool
        switch (withTitle) {
            case "MY PROFILE":
                show = currentMemberRole != MemberRoles.Anonymous
            case "login":
                show = currentMemberRole == MemberRoles.Anonymous
            default:
                show = true
        }
        return show
        
    }
    
    public func login() {
        viewController.showActivityIndicator()
        viewController.hideMenu()
        
        interactor.login { error in
            defer { self.viewController.hideActivityIndicator() }
            
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
            
            self.viewController.hideActivityIndicator()
            self.viewController.reloadMenu()
        }
    }
    
    public func logout() {
        viewController.showActivityIndicator()

        interactor.logout() {error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            self.viewController.hideMenu()
            self.viewController.reloadMenu()
            self.viewController.navigateToHome()
            self.viewController.hideActivityIndicator()
        }
    }
    
    func showPersonProfile(person: PersonDTO?, error: NSError? = nil) {
        dispatch_async(dispatch_get_main_queue(),{
            self.viewController.picUrl = person!.pictureUrl
            self.viewController.hideActivityIndicator()
        })
    }
}
