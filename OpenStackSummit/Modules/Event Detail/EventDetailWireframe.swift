//
//  EventDetailWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventDetailWireframe {
    func presentEventDetailView(eventId: Int, viewController: UINavigationController)
    func showFeedbackEdit(eventId: Int)
    func showSpeakerProfile(speakerId: Int)
    func showVenueDetail(venueId: Int)
    func showVenueRoomDetail(venueRoomId: Int)
}

public class EventDetailWireframe: NSObject {
    var eventDetailViewController : EventDetailViewController!
    var feedbackEditWireframe: IFeedbackEditWireframe!
    var memberProfileWireframe: IMemberProfileWireframe!
    var venueRoomDetailWireframe: IVenueRoomDetailWireframe!
    var venueDetailWireframe: IVenueDetailWireframe!
    
    public func showVenueDetail(venueId: Int) {
        venueDetailWireframe.presentVenueDetailView(venueId, viewController: eventDetailViewController.navigationController!)
    }
    
    public func showVenueRoomDetail(venueRoomId: Int) {
        venueRoomDetailWireframe.presentVenueRoomDetailView(venueRoomId, viewController: eventDetailViewController.navigationController!)
    }
    
    public func presentEventDetailView(eventId: Int, viewController: UINavigationController) {
        let newViewController = eventDetailViewController!
        let _ = eventDetailViewController.view! // this is only to force viewLoad to trigger
        eventDetailViewController.presenter.viewLoad(eventId)
        viewController.pushViewController(newViewController, animated: true)
    }
    
    public func showFeedbackEdit(eventId: Int) {
        feedbackEditWireframe.presentFeedbackEditView(eventId, viewController: eventDetailViewController.navigationController!)
    }
    
    public func showSpeakerProfile(speakerId: Int) {
        memberProfileWireframe.presentSpeakerProfileView(speakerId, viewController: eventDetailViewController.navigationController!)
    }
}
