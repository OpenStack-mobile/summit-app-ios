//
//  PeopleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

@objc
public protocol IPeopleWireframe {
    func pushPeopleView()
    func pushSpeakersView()
    func showAttendeeProfile(attendeeId: Int, fromViewController viewController: UIViewController)
    func showSpeakerProfile(speakerId: Int, fromViewController viewController: UIViewController)
}

public class PeopleWireframe: NSObject, IPeopleWireframe {
    var revealViewController: SWRevealViewController!
    var navigationController: NavigationController!
    var speakersViewController: SpeakersViewController!
    var memberProfileWireframe: IMemberProfileWireframe!
    //var attendeesListViewController: IPeopleListViewController!
    //var speakersListViewController: IPeopleListViewController!
    
    public func pushPeopleView() {
        // TODO: Push people view
    }
    
    public func pushSpeakersView() {
        navigationController.setViewControllers([speakersViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    public func showAttendeeProfile(attendeeId: Int, fromViewController viewController: UIViewController) {
        //memberProfileWireframe.pushAttendeeProfileView(attendeeId, toNavigationController: viewController.navigationController!)
    }
    
    public func showSpeakerProfile(speakerId: Int, fromViewController viewController: UIViewController) {
        memberProfileWireframe.pushSpeakerProfileView(speakerId, toNavigationController: viewController.navigationController!)
    }
}
