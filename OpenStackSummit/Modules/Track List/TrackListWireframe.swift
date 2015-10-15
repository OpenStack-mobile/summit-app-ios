//
//  TrackListWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackListWireframe {
    func showTrackSchedule(trackId: Int)
}

public class TrackListWireframe: NSObject, ITrackListWireframe {
    var trackScheduleWireframe: ITrackScheduleWireframe!
    var trackListViewController: ITrackListViewController!
    
    public func showTrackSchedule(trackId: Int) {
        trackScheduleWireframe.presentTrackScheduleView(trackId, viewController: trackListViewController.navigationController!)
    }
}
