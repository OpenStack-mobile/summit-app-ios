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
}

public class PeopleWireframe: NSObject, IPeopleWireframe {
    var memberProfileWireframe : IMemberProfileWireframe!
    var peopleViewController: IPeopleViewController!
    
    public func showAttendeeProfile(attendeeId: Int) {
        memberProfileWireframe.presentAttendeeProfileView(attendeeId, viewController: peopleViewController.navigationController!)
    }

}
