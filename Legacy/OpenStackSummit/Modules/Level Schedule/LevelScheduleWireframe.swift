//
//  LevelScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol LevelScheduleWireframeProtocol: ScheduleWireframe {
    func presentLevelScheduleView(level: String, viewController: UINavigationController)
}

public class LevelScheduleWireframe: ScheduleWireframe, LevelScheduleWireframeProtocol {
    var levelScheduleViewController: LevelScheduleViewController!
    
    public func presentLevelScheduleView(level: String, viewController: UINavigationController) {
        let newViewController = levelScheduleViewController!
        let _ = levelScheduleViewController.view! // this is only to force viewLoad to trigger
        levelScheduleViewController.presenter.viewLoad(level)
        viewController.pushViewController(newViewController, animated: true)
    }
    
    public func showEventDetail(eventId: Int) {
        
        showEventDetail(eventId, fromViewController: levelScheduleViewController)
    }
}
