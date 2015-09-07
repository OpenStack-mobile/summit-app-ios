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
    func handleMenuItemSelected(section: Int, row: Int)
}

public class MenuPresenter: NSObject, IMenuPresenter {
    var interactor: IMenuInteractor!
    var menuWireframe: IMenuWireframe!
    var router: IRouter!
    
    public override init() {
        super.init()
    }
    
    public init(interactor: IMenuInteractor, menuWireframe: IMenuWireframe) {
        self.interactor = interactor
        self.menuWireframe = menuWireframe
    }
    
    public func hasAccessToMenuItem(section: Int, row: Int) -> Bool {
        
        let currentMemberRole = interactor.getCurrentMemberRole()
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
    
    public func handleMenuItemSelected(section: Int, row: Int) {
        router.navigateToRoot(View.GeneralSchedule, params: nil)
    }
}
