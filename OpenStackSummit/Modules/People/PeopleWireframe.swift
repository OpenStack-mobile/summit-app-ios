//
//  PeopleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IPeopleWireframe {
    func showAttendeeProfile(attendeeId: Int)
    func showSpeakerProfile(speakerId: Int)
}

public class PeopleWireframe: NSObject, IPeopleWireframe {
    var memberProfileWireframe: IMemberProfileWireframe!
    var myProfileWireframe: IMyProfileWireframe!
    var attendeesListViewController: IPeopleListViewController!
    var speakersListViewController: IPeopleListViewController!
    
    public func showAttendeeProfile(attendeeId: Int) {
        memberProfileWireframe.presentAttendeeProfileView(attendeeId, viewController: attendeesListViewController.navigationController!)
    }
    
    public func showSpeakerProfile(speakerId: Int) {
        myProfileWireframe.presentMyProfileInterfaceFromRevealViewController(speakerId, revealViewController: speakersListViewController.navigationController!.revealViewController())    }
}
