//
//  EventDetailWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class EventDetailWireframe: NSObject {
    var eventDetailViewController : EventDetailViewController?
    
    func presentEventDetailView(eventId: Int, viewController: UINavigationController) {
        let newViewController = eventDetailViewController!
        eventDetailViewController?.presenter?.eventId = eventId
        viewController.pushViewController(newViewController, animated: true)
    }
}
