//
//  MemberProfilePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfilePresenter {
    var memberId: Int { get set }
    
    func showMemberProfile()
    func requestFriendship()
}

public class MemberProfilePresenter: NSObject, IMemberProfilePresenter {
    var memberProfileWireframe: IMemberProfileWireframe!
    var interactor: IMemberProfileInteractor!
    var viewController: IMemberProfileViewController!
    public var memberId = 0
    
    public func showMemberProfile() {
        interactor.getMember(memberId) { member, error in
            
            if (error != nil) {
                self.viewController.showProfile(member!)
            }
            else {
                self.viewController.handlerError(error!)
            }
        }
    }
    
    public func requestFriendship() {
        if (!interactor.isLoggedIn()) {
            memberProfileWireframe.showLoginView()
        }
        interactor.requestFriendship(memberId) { error in
            if (error != nil) {
                self.viewController.didFinishFriendshipRequest()
            }
            else {
                self.viewController.handlerError(error!)
            }
            
        }
    }
}
