//
//  EventDetailWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

/* This wireframe is different because we were getting errors when event detail was called in a loop. Example events-> event detail-> speaker profile -> event detail.
To avoid the same view controller to be pushed twice on navigation controller, we create a new one every time presentEventDetailView is called. At some point we should refactor the rest of the wireframes to be similar to this since I believe is a more solid solution */

@objc
public protocol IEventDetailWireframe {
    func pushEventDetailView(eventId: Int, toNavigationViewController navigationController: UINavigationController)
    func showFeedbackEdit(eventId: Int, fromViewController viewController: IEventDetailViewController)
    func showSpeakerProfile(speakerId: Int, fromViewController viewController: IEventDetailViewController)
    func showVenueDetail(venueId: Int, fromViewController viewController: IEventDetailViewController)
    func showVenueLocationDetail(venueId: Int, fromViewController viewController: IEventDetailViewController)
}

public class EventDetailWireframe: NSObject {
    var feedbackEditWireframe: IFeedbackEditWireframe!
    var memberProfileWireframe: IMemberProfileWireframe!
    var venueDetailWireframe: IVenueDetailWireframe!
    
    public func pushEventDetailView(eventId: Int, toNavigationViewController navigationController: UINavigationController) {
        let eventDetailViewController = EventDetailAssembly().activate().eventDetailViewController() as! EventDetailViewController
        eventDetailViewController.presenter.eventId = eventId
        navigationController.pushViewController(eventDetailViewController, animated: true)
    }
    
    public func showVenueDetail(venueId: Int, fromViewController viewController: IEventDetailViewController) {
        venueDetailWireframe.presentVenueDetailView(venueId, viewController: viewController.navigationController!)
    }
    
    public func showVenueLocationDetail(venueId: Int, fromViewController viewController: IEventDetailViewController) {
        venueDetailWireframe.presentVenueLocationDetailView(venueId, viewController: viewController.navigationController!)
    }
    
    public func showFeedbackEdit(eventId: Int, fromViewController viewController: IEventDetailViewController) {
        feedbackEditWireframe.presentFeedbackEditView(eventId, viewController: viewController.navigationController!)
    }
    
    public func showSpeakerProfile(speakerId: Int, fromViewController viewController: IEventDetailViewController) {
        memberProfileWireframe.pushSpeakerProfileView(speakerId, toNavigationController: viewController.navigationController!)
    }
}
