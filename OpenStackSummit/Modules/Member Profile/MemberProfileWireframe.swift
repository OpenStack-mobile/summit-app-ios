//
//  MemberProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

@objc
public protocol IMemberProfileWireframe {
    func pushSpeakerProfileView(speakerId: Int, toNavigationController navigationController: UINavigationController)
}

public class MemberProfileWireframe: NSObject, IMemberProfileWireframe {
    var memberProfileViewController: MemberProfileViewController!
    
    public func pushSpeakerProfileView(speakerId: Int, toNavigationController navigationController: UINavigationController) {
        memberProfileViewController.presenter.prepareForSpeakerProfile(speakerId)
        let _ = memberProfileViewController.view! // this is only to force viewLoad to trigger
        navigationController.pushViewController(memberProfileViewController, animated: true)
    }
}
