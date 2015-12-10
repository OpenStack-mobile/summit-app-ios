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
    func showTrackSchedule(track: TrackDTO)
}

public class TrackListWireframe: NSObject, ITrackListWireframe {
    var trackScheduleWireframe: ITrackScheduleWireframe!
    var trackListViewController: ITrackListViewController!
    
    public func showTrackSchedule(track: TrackDTO) {
        trackScheduleWireframe.presentTrackScheduleView(track, viewController: trackListViewController.navigationController!)
    }
}
