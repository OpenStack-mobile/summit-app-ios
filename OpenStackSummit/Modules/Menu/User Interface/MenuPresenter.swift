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
    func hasAccessToMenuItem(section: Int, row: Int) -> Bool
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
        // TODO: move this to launch screen or landing page
        if securityManager.getCurrentMember() == nil {
            interactor.unsubscribeFromPushChannels() { (succeeded: Bool, error: NSError?) in
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                }
            }
        }
    }
    
    public func hasAccessToMenuItem(section: Int, row: Int) -> Bool {
        
        let currentMemberRole = securityManager.getCurrentMemberRole()
        var show = true
        if (section == 1) {
            if (row == 2) {
                show = currentMemberRole != MemberRoles.Anonymous
            }
        }
        if (section == 2) {
            if (row == 0 || row == 2) {
                show = currentMemberRole != MemberRoles.Anonymous
            }
            else {
                show = currentMemberRole == MemberRoles.Anonymous
            }
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
}
