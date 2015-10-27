//
//  GeneralScheduleFilterWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IGeneralScheduleFilterWireframe {
    func presentFiltersView(viewController: UINavigationController)
}

public class GeneralScheduleFilterWireframe: NSObject {

    var generalScheduleFilterViewController: GeneralScheduleFilterViewController!
    
    public func presentFiltersView(viewController: UINavigationController) {
        let newViewController = generalScheduleFilterViewController!
        let _ = generalScheduleFilterViewController.view! // this is only to force viewLoad to trigger
        generalScheduleFilterViewController.presenter.viewLoad()
        viewController.pushViewController(newViewController, animated: true)
    }
}
