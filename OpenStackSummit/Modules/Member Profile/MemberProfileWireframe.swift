//
//  MemberProfileWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController
import XLPagerTabStrip

@objc
public protocol IMemberProfileWireframe {
    func presentSpeakerProfileView(speakerId: Int, viewController: UINavigationController)
    func presentSpeakerProfileViewFromRevealViewController(speakerId: Int, revealViewController: SWRevealViewController)
}

public class MemberProfileWireframe: NSObject, IMemberProfileWireframe {
    var navigationController: UINavigationController!
    var memberProfileViewController: MemberProfileViewController!
    
    public func presentSpeakerProfileView(speakerId: Int, viewController: UINavigationController) {
        let newViewController = memberProfileViewController!
        memberProfileViewController.presenter.prepareForSpeakerProfile(speakerId)
        navigationController.setViewControllers([memberProfileViewController], animated: false)
        viewController.pushViewController(newViewController, animated: true)
    }

    public func presentSpeakerProfileViewFromRevealViewController(speakerId: Int, revealViewController: SWRevealViewController) {
        let _ = memberProfileViewController.view! // this is only to force viewLoad to trigger
        memberProfileViewController.presenter.prepareForSpeakerProfile(speakerId)
        navigationController.setViewControllers([memberProfileViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
}
