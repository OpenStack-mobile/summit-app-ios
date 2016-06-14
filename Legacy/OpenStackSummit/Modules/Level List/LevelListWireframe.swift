//
//  LevelListWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ILevelListWireframe {
    func showLevelSchedule(level: String)
}

public class LevelListWireframe: NSObject, ILevelListWireframe {
    var levelScheduleWireframe: ILevelScheduleWireframe!
    var levelListViewController: ILevelListViewController!
    
    public func showLevelSchedule(level: String) {
        levelScheduleWireframe.presentLevelScheduleView(level, viewController: levelListViewController.navigationController!)
    }
}

