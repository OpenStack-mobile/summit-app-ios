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
    func showVenueLocationDetail(venueId: Int)
}

public class EventDetailWireframe: NSObject {
    var eventDetailViewController : EventDetailViewController!
    var feedbackEditWireframe: IFeedbackEditWireframe!
    var memberProfileWireframe: IMemberProfileWireframe!
    var venueDetailWireframe: IVenueDetailWireframe!
    
    public func showVenueDetail(venueId: Int) {
        venueDetailWireframe.presentVenueDetailView(venueId, viewController: eventDetailViewController.navigationController!)
    }
    
    public func showVenueLocationDetail(venueId: Int) {
        venueDetailWireframe.presentVenueLocationDetailView(venueId, viewController: eventDetailViewController.navigationController!)
    }
    
    public func presentEventDetailView(eventId: Int, viewController: UINavigationController) {
        let newViewController = eventDetailViewController!
        let _ = eventDetailViewController.view! // this is only to force viewLoad to trigger
        eventDetailViewController.presenter.eventId = eventId
        viewController.pushViewController(newViewController, animated: true)
    }
    
    public func showFeedbackEdit(eventId: Int) {
        feedbackEditWireframe.presentFeedbackEditView(eventId, viewController: eventDetailViewController.navigationController!)
    }
    
    public func showSpeakerProfile(speakerId: Int) {
        memberProfileWireframe.presentSpeakerProfileView(speakerId, viewController: eventDetailViewController.navigationController!)
    }
}
