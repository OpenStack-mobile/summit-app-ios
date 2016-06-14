//
//  TrackListWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

public protocol TrackListWireframeProtocol {
    func showTrackSchedule(track: Track)
}

public class TrackListWireframe: TrackListWireframeProtocol {
    
    var trackScheduleWireframe = TrackScheduleWireframe()
    var trackListViewController: ITrackListViewController!
    
    public func showTrackSchedule(track: Track) {
        trackScheduleWireframe.presentTrackScheduleView(track, toNavigationController: trackListViewController.navigationController!)
    }
}
