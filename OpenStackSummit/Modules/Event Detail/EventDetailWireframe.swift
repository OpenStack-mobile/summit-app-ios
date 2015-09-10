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
}

public class EventDetailWireframe: NSObject {
    var eventDetailViewController : EventDetailViewController!
    
    public func presentEventDetailView(eventId: Int, viewController: UINavigationController) {
        let newViewController = eventDetailViewController!
        let _ = eventDetailViewController.view! // this is only to force viewLoad to trigger
        eventDetailViewController.presenter.prepareEventDetail(eventId)
        viewController.pushViewController(newViewController, animated: true)
    }
}
