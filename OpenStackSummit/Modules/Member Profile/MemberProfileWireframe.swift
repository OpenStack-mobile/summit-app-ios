//
//  MemberProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfileWireframe {
    func showLoginView()
    func presentAttendeeProfileView(attendeeId: Int, viewController: UINavigationController)
}

public class MemberProfileWireframe: NSObject, IMemberProfileWireframe {
    var memberProfileViewController: MemberProfileViewController!
    var loginWireframe: ILoginWireframe!
    
    public func showLoginView() {
        loginWireframe.presentLoginView(memberProfileViewController)
    }
    
    public func presentAttendeeProfileView(attendeeId: Int, viewController: UINavigationController) {
        let newViewController = memberProfileViewController!
        let _ = memberProfileViewController.view! // this is only to force viewLoad to trigger
        memberProfileViewController.presenter.prepareAttendeeProfile(attendeeId)
        viewController.pushViewController(newViewController, animated: true)
    }
}
