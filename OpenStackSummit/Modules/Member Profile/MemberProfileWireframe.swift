//
//  MemberProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
protocol IMemberProfileWireframe {
    func presentAttendeeProfileView(attendeeId: Int, viewController: UINavigationController)
    func presentSpeakerProfileView(attendeeId: Int, viewController: UINavigationController)
    func speakerProfileViewController(speakerId: Int) -> MemberProfileViewController
}

class MemberProfileWireframe: NSObject, IMemberProfileWireframe {
    var memberProfileViewController: MemberProfileViewController!
    
    func presentAttendeeProfileView(attendeeId: Int, viewController: UINavigationController) {
        let newViewController = memberProfileViewController!
        let _ = memberProfileViewController.view! // this is only to force viewLoad to trigger
        memberProfileViewController.presenter.attendeeId = attendeeId
        viewController.pushViewController(newViewController, animated: true)
    }
    
    func presentSpeakerProfileView(speakerId: Int, viewController: UINavigationController) {
        let newViewController = speakerProfileViewController(speakerId)
        viewController.pushViewController(newViewController, animated: true)
    }
    
    func speakerProfileViewController(speakerId: Int) -> MemberProfileViewController {
        let newViewController = memberProfileViewController!
        memberProfileViewController.presenter.speakerId = speakerId
        return newViewController
    }
    
}
