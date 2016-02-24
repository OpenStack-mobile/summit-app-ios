//
//  TrackScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackScheduleWireframe: IScheduleWireframe {
    func presentTrackScheduleView(track: TrackDTO, toNavigationController navigationController: UINavigationController)
}

public class TrackScheduleWireframe: ScheduleWireframe, ITrackScheduleWireframe {
    var trackScheduleViewController: TrackScheduleViewController!
    
    public func presentTrackScheduleView(track: TrackDTO, toNavigationController navigationController: UINavigationController) {
        let newViewController = trackScheduleViewController!
        let _ = trackScheduleViewController.view! // this is only to force viewLoad to trigger
        trackScheduleViewController.presenter.viewLoad(track)
        navigationController.pushViewController(newViewController, animated: true)
    }
    
    public override func showEventDetail(eventId: Int) {
        super.showEventDetail(eventId, fromViewController: trackScheduleViewController)
    }    
}
