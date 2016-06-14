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
    func presentFiltersView(viewController: UIViewController)
    func dismissFilterView()
}

public class GeneralScheduleFilterWireframe: NSObject, IGeneralScheduleFilterWireframe {
    var navigationController: UINavigationController!
    var generalScheduleFilterViewController: GeneralScheduleFilterViewController!
    
    public func presentFiltersView(viewController: UIViewController) {
        let _ = generalScheduleFilterViewController.view! // this is only to force viewLoad to trigger
        generalScheduleFilterViewController.presenter.viewLoad()
        navigationController.pushViewController(generalScheduleFilterViewController, animated: false)
        viewController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    public func dismissFilterView() {
        let presentingViewController = navigationController.presentingViewController!
        presentingViewController.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.navigationController.setViewControllers([], animated: false)
        })
    }
}
