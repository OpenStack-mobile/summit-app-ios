//
//  LevelScheduleWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ILevelScheduleWireframe: IScheduleWireframe {
    func presentLevelScheduleView(level: String, viewController: UINavigationController)
}

public class LevelScheduleWireframe: ScheduleWireframe, ILevelScheduleWireframe {
    var levelScheduleViewController: LevelScheduleViewController!
    
    public func presentLevelScheduleView(level: String, viewController: UINavigationController) {
        let newViewController = levelScheduleViewController!
        let _ = levelScheduleViewController.view! // this is only to force viewLoad to trigger
        levelScheduleViewController.presenter.viewLoad(level)
        viewController.pushViewController(newViewController, animated: true)
    }
    
    public override func showEventDetail(eventId: Int) {
        super.showEventDetail(eventId, fromViewController: levelScheduleViewController)
    }
}
