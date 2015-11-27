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
    func presentAttendeeProfileView(attendeeId: Int, viewController: UINavigationController)
    func presentSpeakerProfileView(attendeeId: Int, viewController: UINavigationController)
}

public class MemberProfileWireframe: NSObject, IMemberProfileWireframe {
    var memberProfileViewController: MemberProfileViewController!
    
    public func presentAttendeeProfileView(attendeeId: Int, viewController: UINavigationController) {
        let newViewController = memberProfileViewController!
        let _ = memberProfileViewController.view! // this is only to force viewLoad to trigger
        memberProfileViewController.presenter.attendeeId = attendeeId
        viewController.pushViewController(newViewController, animated: true)
    }
    
    public func presentSpeakerProfileView(speakerId: Int, viewController: UINavigationController) {
        let newViewController = memberProfileViewController!
        let _ = memberProfileViewController.view! // this is only to force viewLoad to trigger
        memberProfileViewController.presenter.speakerId = speakerId
        viewController.pushViewController(newViewController, animated: true)
    }
}
