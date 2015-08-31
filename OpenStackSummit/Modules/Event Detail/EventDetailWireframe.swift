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
        eventDetailViewController.presenter.eventId = eventId
        viewController.pushViewController(newViewController, animated: true)
    }
}
