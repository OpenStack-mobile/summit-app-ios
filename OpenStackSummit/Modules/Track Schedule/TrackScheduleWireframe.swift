//
//  TrackScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

public protocol TrackScheduleWireframeProtocol: ScheduleWireframe {
    func presentTrackScheduleView(track: Track, toNavigationController navigationController: UINavigationController)
}

public class TrackScheduleWireframe: ScheduleWireframe, TrackScheduleWireframeProtocol {
    
    var trackScheduleViewController: TrackScheduleViewController!
    
    public func presentTrackScheduleView(track: Track, toNavigationController navigationController: UINavigationController) {
        
        let newViewController = trackScheduleViewController!
        let _ = trackScheduleViewController.view! // this is only to force viewLoad to trigger
        trackScheduleViewController.presenter.viewLoad(track)
        navigationController.pushViewController(newViewController, animated: true)
    }
    
    public func showEventDetail(eventId: Int) {
        
        showEventDetail(eventId, fromViewController: trackScheduleViewController)
    }    
}
