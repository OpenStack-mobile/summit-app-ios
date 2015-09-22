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
    
    public func hasAccessToMenuItem(section: Int, row: Int) -> Bool {
        
        let currentMemberRole = securityManager.getCurrentMemberRole()
        var show = true
        if (section == 3) {
            if ((row == 0 || row == 1 || row == 3 || row == 5 || row == 7)) {
                show = currentMemberRole != MemberRoles.Anonymous
            }
            else if (row == 2 || row == 4) {
                show = currentMemberRole == MemberRoles.Speaker
            }
            else if (row == 6) {
                show = currentMemberRole == MemberRoles.Anonymous
            }
        }
        return show
    }
    
    public func login() {
        viewController.showActivityIndicator()
        viewController.hideMenu()
        
        securityManager.login { error in
            self.viewController.hideActivityIndicator()
            self.viewController.reloadMenu()
        }
    }
    
    public func logout() {
        viewController.showActivityIndicator()

        securityManager.logout() {error in
            self.viewController.hideMenu()
            self.viewController.reloadMenu()
            self.viewController.navigateToHome()
            self.viewController.hideActivityIndicator()
        }
    }
}
