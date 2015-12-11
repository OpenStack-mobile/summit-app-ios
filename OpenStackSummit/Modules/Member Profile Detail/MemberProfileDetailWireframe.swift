//
//  MemberProfileDetailWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/11/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
protocol IMemberProfileDetailWireframe {
    func presentAttendeeProfileView(attendeeId: Int, viewController: UINavigationController)
    func presentSpeakerProfileView(attendeeId: Int, viewController: UINavigationController)
    func speakerProfileViewController(speakerId: Int) -> MemberProfileDetailViewController
}

class MemberProfileDetailWireframe: NSObject, IMemberProfileDetailWireframe {
    var memberProfileDetailViewController: MemberProfileDetailViewController!
    
    func presentAttendeeProfileView(attendeeId: Int, viewController: UINavigationController) {
        let newViewController = memberProfileDetailViewController!
        let _ = memberProfileDetailViewController.view! // this is only to force viewLoad to trigger
        memberProfileDetailViewController.presenter.attendeeId = attendeeId
        viewController.pushViewController(newViewController, animated: true)
    }
    
    func presentSpeakerProfileView(speakerId: Int, viewController: UINavigationController) {
        let newViewController = speakerProfileViewController(speakerId)
        viewController.pushViewController(newViewController, animated: true)
    }
    
    func speakerProfileViewController(speakerId: Int) -> MemberProfileDetailViewController {
        let newViewController = memberProfileDetailViewController!
        memberProfileDetailViewController.presenter.speakerId = speakerId
        return newViewController
    }
}