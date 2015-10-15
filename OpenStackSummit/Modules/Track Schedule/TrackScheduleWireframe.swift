//
//  TrackScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackScheduleWireframe {
    func presentTrackScheduleView(trackId: Int, viewController: UINavigationController)
    func showEventDetail(eventId: Int)
}

public class TrackScheduleWireframe: NSObject, ITrackScheduleWireframe {
    var trackScheduleViewController : TrackScheduleViewController!
    var eventDetailWireframe : IEventDetailWireframe!
    
    public func presentTrackScheduleView(trackId: Int, viewController: UINavigationController) {
        let newViewController = trackScheduleViewController!
        let _ = trackScheduleViewController.view! // this is only to force viewLoad to trigger
        trackScheduleViewController.presenter.viewLoad(trackId)
        viewController.pushViewController(newViewController, animated: true)
    }
    
    public func showEventDetail(eventId: Int) {
        eventDetailWireframe.presentEventDetailView(eventId, viewController: trackScheduleViewController.navigationController!)
    }    
}
